attributes = default['cloudless-box']

attributes['applications.prefix'] = 'deploy'
attributes['applications'] = %w{vision foundation}

attributes['applications.vision.layout'] = 'rails'
attributes['applications.vision.ruby'] = '2.2.2'
attributes['applications.vision.database'] = 'postgresql'
attributes['applications.vision.url'] = 'www.agarchia.pl'
attributes['applications.vision.repository'] = 'git@bitbucket.org:karolsluszniak/vision.git'

