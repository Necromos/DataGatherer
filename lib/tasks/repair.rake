namespace :repair do
  desc "Joins duplicated personal_data"
  task join: :environment do

    puts 'Records before repair process: '+PersonalDatum.all.count.to_s
    PersonalDatum.all.each do |item|
      i = item.id
      if !PersonalDatum.where(id: i).first.nil?
        a = PersonalDatum.find(i)
        aids = [].concat a.self_esteem_ids
        a.self_esteem_ids = []
        ca, ua = a.created_at, a.updated_at
        a.created_at, a.updated_at = nil, nil
        id = a.id
        a.id = 0
        PersonalDatum.all.each do |pd|
          if id != pd.id
            pdids = pd.self_esteem_ids
            pd.self_esteem_ids = []
            pd.created_at, pd.updated_at = nil, nil
            pdid = pd.id
            pd.id = 0
            if pd == a
              puts 'Repairing record number '+pdid.to_s
              aids.concat pdids
              PersonalDatum.destroy(pdid)
            end
          end
        end
        a.created_at, a.updated_at = ca, ua
        a.id = id
        puts aids.inspect
        a.self_esteem_ids = aids
        puts a.save ? 'saved!' : 'nope :('
      end
    end
    puts 'Records after repair process: '+ PersonalDatum.all.count.to_s
  end

end
