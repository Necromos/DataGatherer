namespace :classify do
  desc "Testing full classification task"
  task full: :environment do
    puts "\n\nContext + data classification"
    data_set = []
    labels = ["age", "nationality", "living_country", "health_issues", "chronic_diseases", "smoker", "alcoholic", "druggy", "disabled", "sex", "psychotropic", "stress", "alcohol", "tabacco", "drugs", "walking_time_per_day", "jogging_time_per_day", "gym_workout_time_per_day", "swimming_time_per_day",
      "wholesome_food_per_day", "junk_food_per_day", "weather", "season", "self_esteem" ]
    PersonalDatum.all.each do |personal_record|
      tmp = personal_record.to_array
      personal_record.self_esteems.each do |self_esteem|
        data_set.push(tmp + self_esteem.to_array)
      end
    end
    ex = [20,"Polish", "Poland", false, false, false, false, false, false, "Male", false, true, 0, 0, 0, 50, 0, 0, 0, 3, 4, "Windy", "Spring"]
    classify(data_set, labels, ex)
  end

  desc "Testing data only classification task"
  task data: :environment do
    puts "\n\nData classification"
    data_set = []
    labels = ["alcohol", "tabacco", "drugs", "walking_time_per_day", "jogging_time_per_day", "gym_workout_time_per_day", "swimming_time_per_day",
      "wholesome_food_per_day", "junk_food_per_day", "weather", "season", "self_esteem" ]
    SelfEsteem.all.each do |self_esteem|
      data_set.push self_esteem.to_array
    end
    ex = [0, 0, 0, 50, 0, 0, 0, 3, 4, "Windy", "Spring"]
    classify(data_set, labels, ex)
  end

  desc 'Do all!'
  task all: [:full, :data] do
    puts "\n\nDone!"
  end

  desc 'no personalization test'
  task first_test: :environment do
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    app = Rjb::import("com.mgr.classification.App").new()
    csv_string = get_all_self_esteem_csv
    JStr = Rjb::import('java.lang.String')
    csv_string = JStr.new_with_sig('Ljava.lang.String;', csv_string)
    p app.runAll(csv_string)
  end

  desc 'distance test'
  task second_test: :environment do
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
    distance = Rjb::import("weka.core.EuclideanDistance").new(data)
    man_distance = Rjb::import("weka.core.ManhattanDistance").new(data)
    cheb_distance = Rjb::import("weka.core.ChebyshevDistance").new(data)
    count = PersonalDatum.all.count
    p "Euclidean"
    results = distance(data, distance)
    filter_and_compute_distance_results(app,count,results,1.5)
    p "Manhattan"
    results = distance(data, man_distance)
    filter_and_compute_distance_results(app,count,results,2)
    p "Chebyshev"
    results = distance(data, cheb_distance)
    filter_and_compute_distance_results(app,count,results,1)
  end

  desc 'Third test'
  task third_test: :environment do
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
    euc_classifiation_res, man_classification_res, che_classification_re = [], [], []
    (1..SelfEsteem.all.count).each do |j|
      arr = get_self_esteem_csv_by_id(j)
      euc_classifiation_res << filter_and_compute_distance_results_without_one_id(app,arr[0],euc_results,count,1.5,arr[1])
      man_classification_res << filter_and_compute_distance_results_without_one_id(app,arr[0],man_results,count,2.0,arr[1])
      che_classification_re << filter_and_compute_distance_results_without_one_id(app,arr[0],che_results,count,1.0,arr[1])
    end
    p "Euclidean"
    p euc_classifiation_res
    p "Manhattan"
    p man_classification_res
    p "Chebyshev"
    p che_classification_re
  end

  private

  def filter_and_compute_distance_results_without_one_id(app,id,results,i,max_val,to_classify)
    tmp_res = []
    results.each do |key,val|
      tmp_res << key[1] if key[0] == id && val < max_val
    end
    # p tmp_res
    csv_training_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id_with_pdid(id,tmp_res))
    # p csv_training_string.toString
    csv_string_to_classify = JStr.new_with_sig('Ljava.lang.String;', to_classify)
    # p csv_string_to_classify.toString
    app.compareTwo(csv_training_string,csv_string_to_classify)
  end

  def filter_and_compute_distance_results(app,i,results,max_val)
    (1..i).each do |c|
      tmp_res = []
      results.each do |key,val|
        tmp_res << key[1] if key[0] == c && val < max_val
      end
      p tmp_res
      csv_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv(tmp_res))
      p app.runAll(csv_string)
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
      SelfEsteem.where.not(id).each do |se|
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

  def classify(data_set, labels, ex)
    data_set = Ai4r::Data::DataSet.new :data_items=>data_set, :data_labels=>labels
    puts data_set.build_domains.to_s
    naive_bayes = Ai4r::Classifiers::NaiveBayes.new.build data_set
    id3 = Ai4r::Classifiers::ID3.new.build data_set
    # hyperpipes = Ai4r::Classifiers::Hyperpipes.new.build data_set
    prism = Ai4r::Classifiers::Prism.new.build data_set
    ib1 = Ai4r::Classifiers::IB1.new.build data_set
    zero_r = Ai4r::Classifiers::ZeroR.new.build data_set
    # one_r = Ai4r::Classifiers::OneR.new.build data_set
    # mp = Ai4r::Classifiers::MultilayerPerceptron.new.build data_set

    # puts "\nNaiveBayes Probability map: " + naive_bayes.get_probability_map(ex).to_s
    # begin
    #   puts "NaiveBayes Predicted: " + naive_bayes.eval(ex).to_s
    # rescue
    #   puts "NaiveBayes got not enough data"
    # end

    puts "\nID3 rules: " + id3.get_rules
    begin
      puts "ID3 Predicted: " + id3.eval(ex).to_s
    rescue Ai4r::Classifiers::ModelFailureError
      puts "ID3 got not enought data"
    end

    # puts "\nHyperpipes rules: " + hyperpipes.get_rules
    # begin
    #   puts "Hyperpipes Predicted: " + hyperpipes.eval(ex).to_s
    # rescue Ai4r::Classifiers::ModelFailureError
    #   puts "Hyperpipes got not enought data"
    # end

    puts "\nPrism rules: " + prism.get_rules
    begin
      puts "Prism Predicted: " + prism.eval(ex).to_s
    rescue Ai4r::Classifiers::ModelFailureError
      puts "Prism got not enought data"
    end

    puts "\n"
    begin
      tmpeval = ib1.eval(ex)
      puts "IB1 Predicted: " + (tmpeval.nil? ? "nothing" : tmpeval.to_s)
    rescue Ai4r::Classifiers::ModelFailureError
      puts "IB1 got not enought data"
    end

    puts "\nZeroR rules: " + zero_r.get_rules
    begin
      puts "ZeroR Predicted: " + zero_r.eval(ex).to_s
    rescue Ai4r::Classifiers::ModelFailureError
      puts "ZeroR got not enought data"
    end

    # puts "\nOneR rules: " + one_r.get_rules
    # begin
    #   puts "OneR Predicted: " + one_r.eval(ex).to_s
    # rescue Ai4r::Classifiers::ModelFailureError
    #   puts "OneR got not enought data"
    # end

    # puts "\nMultilayerPerceptron rules: " + mp.get_rules
    # begin
    #   puts "MultilayerPerceptron Predicted: " + mp.eval(ex).to_s
    # rescue Ai4r::Classifiers::ModelFailureError
    #   puts "MultilayerPerceptron got not enought data"
    # end
  end
end
