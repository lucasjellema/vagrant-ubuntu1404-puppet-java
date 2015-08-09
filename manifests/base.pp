$my_full_name = "developer"
$my_email = "developer@yourorg.domain"
$oracle_password = 'oracle'
$name=oracle
$group=oracle

/bin/cp -R /etc/skel /home/$oracle; /bin/chown -R $oracle:$oracle /home/$oracle

include java::install

package { "git": ensure => present }
package { "build-essential": ensure => present }
package { "ubuntu-desktop": ensure => present }

group { "oracle":
	ensure		=> present,
}

exec { "restart-lightdm":
	command => "/usr/bin/apt-get install linux-headers-$(uname -r); /etc/init.d/lightdm restart; /usr/bin/touch /etc/puppet/.lightdm",
	creates => "/etc/puppet/.lightdm",
	subscribe => Package['ubuntu-desktop'],
}

user { "oracle":
	ensure		=> present,
	comment		=> "$my_full_name",
	gid			=> "oracle",
	groups		=> ["admin", "sudo" ],
#	membership	=> minimum,
	shell		=> "/bin/bash",
	home		=> "/u01/app/oracle",
}

exec { "set-oracle-password":
	command	=> [ "/bin/echo -e \"$oracle_password\\n$oracle_password\\n\" | /usr/bin/passwd oracle && /usr/bin/passwd -u oracle" ],
	unless	=> "/usr/bin/passwd -S oracle|awk '{print $2}'|grep 'oracle P'",
	require	=> User[oracle],
}

exec { "oracle homedir":
	command	=> "/bin/cp -R /etc/skel /home/$name; /bin/chown -R $name:$group /home/$name",
	creates	=> "/u01/app/oracle",
	require	=> User[oracle],
}

exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
Exec["apt-update"]	-> Package <| |>

# Configure Git
#exec { "setup-git-username":
#	command		=> "/usr/bin/git config --global user.name '$my_full_name'",
#	unless		=> "/usr/bin/git config --global --get user.name|/bin/grep '$my_full_name'",
#	environment	=> "HOME=/u01/app/oracle",
#	user		=> "oracle"
#}

