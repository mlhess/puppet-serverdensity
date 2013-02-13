class apt {

    file {
        'sd-agent.list':
            path    => '/etc/apt/sources.list.d/sd-agent.list',
            ensure  =>  file,
            content => 'deb http://www.serverdensity.com/downloads/linux/deb all main',
            notify  => Exec['sd-apt-update']
    }

    exec {
        'add-sd-apt-key':
            command => '/usr/bin/wget -O - https://www.serverdensity.com/downloads/boxedice-public.key | /usr/bin/apt-key add -',
            require => File['sd-agent.list'],
            
    }

    exec {
        'sd-apt-update':
            command => '/usr/bin/apt-get update',
            require => Exec['add-sd-apt-key'],
    } 

    package {
        'sd-agent':
            ensure => 'present',
            require => Exec['sd-apt-update']
    }    
}

class yum {

    file {
        'sd-agent.repo':
            path    => '/etc/yum.repos.d/serverdensity.repo',
            ensure  =>  file,
            content => '[serverdensity]
name=Server Density
baseurl=http://www.serverdensity.com/downloads/linux/redhat/
enabled=1',
    }

    exec {
        'download-sd-yum-key':
            command => '/usr/bin/wget https://www.serverdensity.com/downloads/boxedice-public.key',
            require => File['sd-agent.repo'],
    }

    exec {
        'import-sd-yum-key':
            command => '/usr/bin/sudo rpm --import boxedice-public.key',
            require => Exec['download-sd-yum-key'],
    }

    exec {
        'delete-sd-yum-key':
            command => '/bin/rm boxedice-public.key',
            require => Exec['import-sd-yum-key'],
    }

    package {
        'sd-agent':
            ensure => 'present',
            require => Exec['delete-sd-yum-key']
    } 
}

class puppet-serverdensity( $content ) {
    case $::operatingsystem {
        'Ubuntu': { include apt }
        'CentOS': { include yum }
    }
}