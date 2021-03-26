package main

deny_not_maintainer[msg] {
	cert_cname := input["certificate-common-name"]
    maintainers := [ maintainer | maintainer := data.maintainers[_]; maintainer.email == cert_cname ]
    count(maintainers) == 0
    msg := sprintf("Certificate with email=%v does not match list of maintainers=%v", [cert_cname, data.maintainers])
}
