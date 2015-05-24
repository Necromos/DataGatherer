namespace :classify do
  desc 'no personalization test'
  task first_test: :environment do
    Rjb::load(Rails.root.join("classification-1.0.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    app = Rjb::import("com.mgr.classification.App").new()
    JStr = Rjb::import('java.lang.String')
    res = []
    (1..SelfEsteem.all.count).each do |j|
      training = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id(j))
      to_classify = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv_by_id(j)[1])
      res << app.compareTwo(training, to_classify)
    end
    p res
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
    csv_training_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_without_id_with_pdid(id,tmp_res))
    csv_string_to_classify = JStr.new_with_sig('Ljava.lang.String;', to_classify)
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
