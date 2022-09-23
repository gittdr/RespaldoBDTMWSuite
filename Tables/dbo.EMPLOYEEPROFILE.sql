CREATE TABLE [dbo].[EMPLOYEEPROFILE]
(
[ee_ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ee_firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_middleinit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_ssn] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_city] [int] NULL,
[ee_Ctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_Country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_Terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_supervisorID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_hiredate] [datetime] NULL,
[ee_terminationdt] [datetime] NULL,
[ee_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_dateofbirth] [datetime] NULL,
[ee_workphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_homephone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_nbrdependents] [tinyint] NULL,
[ee_worklocation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_managementlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_emername] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_emerphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_licensenumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_Licensestate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_maritalstatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_occupation] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_workstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_EEID] ON [dbo].[EMPLOYEEPROFILE] ([ee_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EMPLOYEEPROFILE] TO [public]
GO
GRANT INSERT ON  [dbo].[EMPLOYEEPROFILE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EMPLOYEEPROFILE] TO [public]
GO
GRANT SELECT ON  [dbo].[EMPLOYEEPROFILE] TO [public]
GO
GRANT UPDATE ON  [dbo].[EMPLOYEEPROFILE] TO [public]
GO
