attributes = default['cloudless-box']

attributes['firewall.rules'] = %w(http sshd)
attributes['backup.bucket'] = "cloudless-ks3-backup"
attributes['backup.access_key_id'] = 'AKIAIPH2IZHKA7M6CQYA'
attributes['backup.secret_access_key'] = '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'
attributes['applications.prefix'] = 'deploy'
attributes['applications'] = %w{vision foundation}

attributes['applications.vision.layout'] = 'rails'
attributes['applications.vision.ruby'] = '2.2.2'
attributes['applications.vision.database'] = 'postgresql'
attributes['applications.vision.url'] = 'www.agarchia.pl'
attributes['applications.vision.repository'] = 'git@bitbucket.org:karolsluszniak/vision.git'

