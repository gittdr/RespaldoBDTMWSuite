CREATE TABLE [dbo].[golivecheck_sysadmin]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_users] [int] NULL,
[glc_cnt_groups] [int] NULL,
[glc_pct_usrtogrp] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_sysadmin] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_sysadmin] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_sysadmin] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_sysadmin] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_sysadmin] TO [public]
GO
