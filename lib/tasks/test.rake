namespace :classify do
  desc 'no personalization test'
  task :first_test, [:discretize] => :environment do |t,args|
    puts "====================================================="
    puts "No Personalization test - first test"
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    app = Rjb::import("com.mgr.classification.App").new()
    JStr = Rjb::import('java.lang.String')
    res = []
    (1..SelfEsteem.all.count).each do |j|
      training = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id(j))
      to_classify = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv_by_id(j)[1])
      res << app.compareTwo(training, to_classify, to_boolean(args.discretize))
    end
    print_percent_results(res,true)
    puts "====================================================="
  end

  desc 'active test'
  task :second_test, [:folds,:runs,:discretize] => :environment do |t,args|
    puts "====================================================="
    puts "ActiveApproach test - second test"
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    app = Rjb::import("com.mgr.classification.App").new()
    JStr = Rjb::import('java.lang.String')
    data = JStr.new_with_sig('Ljava.lang.String;', get_all_self_esteem_csv())
    tmp = app.activeApproach(data, args.folds.to_i, args.runs.to_i, to_boolean(args.discretize))
    before = []
    after = []
    tmp.each_with_index do |value,index|
      before << value if index % 2 == 0
      after << value if index % 2 == 1
    end
    puts "Before active approach"
    print_percent_results_from_cube_array(before,true,args.folds,args.runs)
    puts "After active approach"
    print_percent_results_from_cube_array(after,true,args.folds,args.runs)
    puts "====================================================="
  end

  desc 'distance test'
  task :third_test,[:discretize] => :environment do |t,args|
    puts "====================================================="
    puts "Distance test - third test"
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    pd_csv_string = get_all_personal_data_csv
    JStr = Rjb::import('java.lang.String')
    app = Rjb::import("com.mgr.classification.App").new()
    csv_string = JStr.new_with_sig('Ljava.lang.String;', pd_csv_string)
    bais = Rjb::import("java.io.ByteArrayInputStream")
    bais = bais.new(csv_string.getBytes("UTF-8"))
    csvloader = Rjb::import("weka.core.converters.CSVLoader").new()
    csvloader.setSource(bais)
    data = Rjb::import("weka.core.Instances").new(csvloader.getDataSet())
    euc_distance = Rjb::import("weka.core.EuclideanDistance").new(data)
    man_distance = Rjb::import("weka.core.ManhattanDistance").new(data)
    che_distance = Rjb::import("weka.core.ChebyshevDistance").new(data)
    count = PersonalDatum.all.count
    euc_results = distance(data, euc_distance)
    man_results = distance(data, man_distance)
    che_results = distance(data, che_distance)
    euc_classification_res, man_classification_res, che_classification_res = [], [], []
    discretize = to_boolean(args.discretize)
    (1..SelfEsteem.all.count).each do |j|
      arr = get_self_esteem_csv_by_id(j)
      euc_classification_res << filter_and_compute_distance_results_without_one_id(app,arr[0],euc_results,count,1.5,arr[1],discretize)
      man_classification_res << filter_and_compute_distance_results_without_one_id(app,arr[0],man_results,count,2.0,arr[1],discretize)
      che_classification_res << filter_and_compute_distance_results_without_one_id(app,arr[0],che_results,count,1.0,arr[1],discretize)
    end
    puts "Euclidean"
    print_percent_results(euc_classification_res,true)
    puts "Manhattan"
    print_percent_results(man_classification_res,true)
    puts "Chebyshev"
    print_percent_results(che_classification_res,true)
    puts "====================================================="
  end

  desc 'cluster test'
  task :fourth_test,[:discretize] => :environment do |t,args|
    puts "====================================================="
    puts "Cluster test - fourth test"
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    pd_csv_string = get_all_personal_data_csv
    JStr = Rjb::import('java.lang.String')
    app = Rjb::import("com.mgr.classification.App").new()
    csv_string = JStr.new_with_sig('Ljava.lang.String;', pd_csv_string)
    data = app.convertData(csv_string)
    ff = Rjb::import("weka.clusterers.FarthestFirst").new()
    (2..SelfEsteem.all.count/2).each do |n|
      ff.setOptions(["-N",n.to_s])
      ff.buildClusterer(data)
      ff_res = []
      (1..SelfEsteem.all.count).each do |i|
        arr = get_self_esteem_csv_by_id(i)
        elements = get_ids_from_clusters(ff,data,arr[0])
        ff_res << classify_with_clustering(app,arr[0],elements,arr[1],to_boolean(args.discretize))
      end
      puts "FarthestFirst for #{n} clusters"
      print_percent_results(ff_res,true)
    end
    puts "====================================================="
  end

  desc 'distance test with multiple runs'
  task :fifth_test,[:runs,:folds,:discretize] => :environment do |t,args|
    puts "====================================================="
    puts "Distance test - fifth test"
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    pd_csv_string = get_all_personal_data_csv
    JStr = Rjb::import('java.lang.String')
    app = Rjb::import("com.mgr.classification.App").new()
    csv_string = JStr.new_with_sig('Ljava.lang.String;', pd_csv_string)
    bais = Rjb::import("java.io.ByteArrayInputStream")
    bais = bais.new(csv_string.getBytes("UTF-8"))
    csvloader = Rjb::import("weka.core.converters.CSVLoader").new()
    csvloader.setSource(bais)
    data = Rjb::import("weka.core.Instances").new(csvloader.getDataSet())
    euc_distance = Rjb::import("weka.core.EuclideanDistance").new(data)
    man_distance = Rjb::import("weka.core.ManhattanDistance").new(data)
    che_distance = Rjb::import("weka.core.ChebyshevDistance").new(data)
    count = PersonalDatum.all.count
    euc_results = distance(data, euc_distance)
    man_results = distance(data, man_distance)
    che_results = distance(data, che_distance)
    euc_classification_res, man_classification_res, che_classification_res = [], [], []
    discretize = to_boolean(args.discretize)
    (1..SelfEsteem.all.count).each do |j|
      arr = get_self_esteem_csv_by_id(j)
      euc_classification_res << filter_and_compute_distance_results_without_one_id_multiple_times(app,arr[0],euc_results,count,1.5,arr[1],args.folds.to_i,args.runs.to_i,discretize)
      man_classification_res << filter_and_compute_distance_results_without_one_id_multiple_times(app,arr[0],man_results,count,2.0,arr[1],args.folds.to_i,args.runs.to_i,discretize)
      che_classification_res << filter_and_compute_distance_results_without_one_id_multiple_times(app,arr[0],che_results,count,1.0,arr[1],args.folds.to_i,args.runs.to_i,discretize)
    end
    puts "Euclidean"
    print_percent_results_from_cube_array(euc_classification_res,true,args.folds,args.runs)
    puts "Manhattan"
    print_percent_results_from_cube_array(man_classification_res,true,args.folds,args.runs)
    puts "Chebyshev"
    print_percent_results_from_cube_array(che_classification_res,true,args.folds,args.runs)
    puts "====================================================="
  end

  desc 'run complete tests'
  task :run_all, [:folds,:runs,:discretize] => :environment do |t,args|
    Rake.application.invoke_task("classify:first_test["+(args.discretize)+"]")
    Rake.application.invoke_task("classify:second_test["+(args.folds)+","+(args.runs)+","+(args.discretize)+"]")
    Rake.application.invoke_task("classify:third_test["+(args.discretize)+"]")
    Rake.application.invoke_task("classify:fourth_test["+(args.discretize)+"]")
  end

  private

  def to_boolean(str)
    str == 'true'
  end

  def print_percent_results_from_cube_array(res,show,folds,runs)
    end_res = Hash.new
    end_res["NB"] = 0
    end_res["BN"] = 0
    end_res["FT"] = 0
    end_res["RF"] = 0
    end_res["count"] = 0
    (0..res.length-1).each do |i|
      tmp = print_percent_results(res[i],false)
      end_res["NB"] = tmp["NB"] + end_res["NB"]
      end_res["BN"] = tmp["BN"] + end_res["BN"]
      end_res["FT"] = tmp["FT"] + end_res["FT"]
      end_res["RF"] = tmp["RF"] + end_res["RF"]
      end_res["count"] = tmp["count"] + end_res["count"]
    end
    if(show)
      puts end_res
      puts "Naive Bayes %: "+((end_res["NB"] / end_res["count"].to_f) * 100.0).to_s
      puts "Bayes Network %: "+((end_res["BN"] / end_res["count"].to_f) * 100.0).to_s
      puts "Functional Trees %: "+((end_res["FT"] / end_res["count"].to_f) * 100.0).to_s
      puts "Random Forest %: "+((end_res["RF"] / end_res["count"].to_f) * 100.0).to_s
      puts "After active approach with #{folds} folds and after #{runs} runs"
    end
    end_res
  end

  def print_percent_results(res,show)
    end_res = Hash.new
    end_res["NB"] = 0
    end_res["BN"] = 0
    end_res["FT"] = 0
    end_res["RF"] = 0
    end_res["count"] = 0
    res.each do |r|
      end_res["NB"] = end_res["NB"] + 1 if r[0] == r[4] && r[4] != -1.0
      end_res["BN"] = end_res["BN"] + 1 if r[1] == r[4] && r[4] != -1.0
      end_res["FT"] = end_res["FT"] + 1 if r[2] == r[4] && r[4] != -1.0
      end_res["RF"] = end_res["RF"] + 1 if r[3] == r[4] && r[4] != -1.0
      end_res["count"] = end_res["count"] + 1 if r[4] != -1.0
    end
    if(show)
      puts end_res
      puts "Naive Bayes %: "+((end_res["NB"] / res.length.to_f) * 100.0).to_s
      puts "Bayes Network %: "+((end_res["BN"] / res.length.to_f) * 100.0).to_s
      puts "Functional Trees %: "+((end_res["FT"] / res.length.to_f) * 100.0).to_s
      puts "Random Forest %: "+((end_res["RF"] / res.length.to_f) * 100.0).to_s
    end
    end_res
  end

  def get_ids_from_clusters(clusterer,data,id)
    res = Hash.new
    number_of_elements = data.numInstances
    number_of_elements.times do |i|
      res[i+1] = clusterer.clusterInstance(data.instance(i))
    end
    searched_cluster = res[id]
    result = []
    res.each do |index,val|
      result << index if val == searched_cluster
    end
    result
  end

  def classify_with_clustering(app,id,pdid,to_classify,discretize)
    csv_training_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id_with_pdid(id,pdid))
    csv_string_to_classify = JStr.new_with_sig('Ljava.lang.String;', to_classify)
    app.compareTwo(csv_training_string,csv_string_to_classify,discretize)
  end

  def filter_and_compute_distance_results_without_one_id(app,id,results,i,max_val,to_classify,discretize)
    tmp_res = []
    results.each do |key,val|
      tmp_res << key[1] if key[0] == id && val < max_val
    end
    csv_training_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id_with_pdid(id,tmp_res))
    csv_string_to_classify = JStr.new_with_sig('Ljava.lang.String;', to_classify)
    app.compareTwo(csv_training_string,csv_string_to_classify,discretize)
  end

  def filter_and_compute_distance_results_without_one_id_multiple_times(app,id,results,i,max_val,to_classify,folds,runs,discretize)
    tmp_res = []
    results.each do |key,val|
      tmp_res << key[1] if key[0] == id && val < max_val
    end
    csv_training_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id_with_pdid(id,tmp_res))
    csv_string_to_classify = JStr.new_with_sig('Ljava.lang.String;', to_classify)
    app.compareTwo(csv_training_string,csv_string_to_classify,folds,runs,discretize)
  end

  def filter_and_compute_distance_results(app,i,results,max_val)
    (1..i).each do |c|
      tmp_res = []
      results.each do |key,val|
        tmp_res << key[1] if key[0] == c && val < max_val
      end
      puts tmp_res
      csv_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv(tmp_res))
      puts app.runAll(csv_string)
    end
  end

  def distance(data, distance)
    results = Hash.new
    i, j = 1, 1
    data.numInstances.times do |inst|
      data.numInstances.times do |inst2|
        # break if i == j
        results[[i,j]] = distance.distance(data.instance(inst), data.instance(inst2))
        j = j + 1
      end
      i = i + 1
      j = 1
    end
    results
  end

  def get_all_personal_data_csv()
    pd_csv_string = CSV.generate do |csv|
      pd_tmp = PersonalDatum.attribute_names.dup
      pd_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << pd_tmp
      PersonalDatum.all.each do |pd|
        tmp = pd.attributes.values.dup
        tmp.delete_at(0)
        tmp.delete_at(9)
        tmp.delete_at(9)
        csv << tmp
      end
    end
    pd_csv_string
  end

  def get_all_self_esteem_csv()
    se_csv_string = CSV.generate do |csv|
      se_tmp = SelfEsteem.attribute_names.dup
      se_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << se_tmp
      SelfEsteem.all.each do |se|
        tmp = se.attributes.values.dup
        tmp.delete_at(0)
        tmp.delete_at(0)
        tmp.delete_at(12)
        tmp.delete_at(12)
        csv << tmp
      end
    end
    se_csv_string
  end

  def get_self_esteem_without_id_with_pdid(id,pdid)
    se_csv_string = CSV.generate do |csv|
      se_tmp = SelfEsteem.attribute_names.dup
      se_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << se_tmp
      SelfEsteem.where.not(id: id).where(personal_datum_id: pdid).each do |se|
        tmp = se.attributes.values.dup
        tmp.delete_at(0)
        tmp.delete_at(0)
        tmp.delete_at(12)
        tmp.delete_at(12)
        csv << tmp
      end
    end
    se_csv_string
  end

  def get_self_esteem_without_id(id)
    se_csv_string = CSV.generate do |csv|
      se_tmp = SelfEsteem.attribute_names.dup
      se_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << se_tmp
      SelfEsteem.where.not(id: id).each do |se|
        tmp = se.attributes.values.dup
        tmp.delete_at(0)
        tmp.delete_at(0)
        tmp.delete_at(12)
        tmp.delete_at(12)
        csv << tmp
      end
    end
    se_csv_string
  end

  def get_self_esteem_csv_by_id(id)
    se_csv_string = CSV.generate do |csv|
      se_tmp = SelfEsteem.attribute_names.dup
      se_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << se_tmp
      tmp = SelfEsteem.find(id).attributes.values.dup
      tmp.delete_at(0)
      tmp.delete_at(0)
      tmp.delete_at(12)
      tmp.delete_at(12)
      csv << tmp
    end
    [SelfEsteem.find(id).personal_datum_id,se_csv_string]
  end

  def get_self_esteem_csv(ids)
    se_csv_string = CSV.generate do |csv|
      se_tmp = SelfEsteem.attribute_names.dup
      se_tmp.delete_if { |x| x["id"] != nil || x["_at"] != nil }
      csv << se_tmp
      SelfEsteem.where(personal_datum_id: ids).each do |se|
        tmp = se.attributes.values.dup
        tmp.delete_at(0)
        tmp.delete_at(0)
        tmp.delete_at(12)
        tmp.delete_at(12)
        csv << tmp
      end
    end
    se_csv_string
  end
end
