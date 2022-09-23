CREATE TABLE [dbo].[reservedordnumbers]
(
[ron_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reservedordnumbers] TO [public]
GO
GRANT INSERT ON  [dbo].[reservedordnumbers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reservedordnumbers] TO [public]
GO
GRANT SELECT ON  [dbo].[reservedordnumbers] TO [public]
GO
GRANT UPDATE ON  [dbo].[reservedordnumbers] TO [public]
GO
