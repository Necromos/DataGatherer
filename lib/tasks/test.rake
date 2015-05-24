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
    JStr = Rjb::import('java.lang.String')
    results = distance(data, distance)
    p "Euclidean"
    i = PersonalDatum.all.count
    (1..i).each do |c|
      tmp_res = []
      results.each do |key,val|
        tmp_res << key[1] if key[0] == c && val < 1.5
      end
      p tmp_res
      csv_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv(tmp_res))
      p app.runAll(csv_string)
    end
    results = distance(data, man_distance)
    p "Manhattan"
    (1..i).each do |c|
      tmp_res = []
      results.each do |key,val|
        tmp_res << key[1] if key[0] == c && val < 2.0
      end
      p tmp_res
      csv_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv(tmp_res))
      p app.runAll(csv_string)
    end
    results = distance(data, cheb_distance)
    p "Chebyshev"
    (1..i).each do |c|
      tmp_res = []
      results.each do |key,val|
        tmp_res << key[1] if key[0] == c && val < 1.0
      end
      p tmp_res
      csv_string = JStr.new_with_sig('Ljava.lang.String;', get_self_esteem_csv(tmp_res))
      p app.runAll(csv_string)
    end
  end

  desc 'Weka time!'
  task weka: :environment do
    Rjb::load(Rails.root.join("weka.jar").to_s, jvmargs=["-Xmx1000M","-Djava.awt.headless=true"])
    JStr = Rjb::import('java.lang.String')
    csv_string = CSV.generate do |csv|
      csv << SelfEsteem.attribute_names
      SelfEsteem.all.each do |se|
        csv << se.attributes.values
      end
    end
    csv_string = JStr.new_with_sig('Ljava.lang.String;', csv_string)
    bais = Rjb::import("java.io.ByteArrayInputStream")
    bais = bais.new(csv_string.getBytes("UTF-8"))
    csvloader = Rjb::import("weka.core.converters.CSVLoader").new()
    csvloader.setSource(bais)
    data = Rjb::import("weka.core.Instances").new(csvloader.getDataSet())
    data.setClassIndex( data.numAttributes - 3 )
    convert = Rjb::import("weka.filters.unsupervised.attribute.NumericToNominal").new()
    convert.setOptions(["-R","14"])
    convert.setInputFormat(data)
    Filter = Rjb::import("weka.filters.Filter")
    data = Filter.useFilter(data, convert)
    p data.toString
    classifier = Rjb::import("weka.classifiers.bayes.NaiveBayes").new
    instance = Rjb::import("weka.core.Instance").new(data.firstInstance)
    data.delete(0)
    instance.setDataset(data)
    classifier.buildClassifier(data)
    # data.numInstances.times do |instance|
    #   pred = classifier.classifyInstance(data.instance(instance))
    #   p pred
    # end
    p classifier.classifyInstance(instance)
  end

  private

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
