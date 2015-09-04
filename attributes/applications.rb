attributes = default['cloudless-box']

attributes['applications.prefix'] = 'deploy'
attributes['applications'] = %w{vision foundation videku}

attributes['applications.vision.layout'] = 'rails'
attributes['applications.vision.ruby'] = '2.2.2'
attributes['applications.vision.database'] = 'postgresql'
attributes['applications.vision.url'] = 'vision.box'
attributes['applications.vision.repository'] = 'git@bitbucket.org:karolsluszniak/vision.git'

attributes['applications.videku.layout'] = 'node'
attributes['applications.videku.bower'] = true
attributes['applications.videku.url'] = 'videku.box'
attributes['applications.videku.repository'] = 'git@bitbucket.org:karolsluszniak/videoreader.git'
