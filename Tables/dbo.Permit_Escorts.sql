CREATE TABLE [dbo].[Permit_Escorts]
(
[PE_ID] [int] NOT NULL IDENTITY(1, 1),
[PE_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PE_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact_Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact_Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact_Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact2_Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact2_Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Contact2_Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Website] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Escort_Cost] [money] NULL,
[PE_Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_City] [int] NULL,
[PE_City_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Escorts] ADD CONSTRAINT [PK_Permit_Escorts] PRIMARY KEY CLUSTERED ([PE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Escorts] ADD CONSTRAINT [IX_Permit_Escorts_PE_Name] UNIQUE NONCLUSTERED ([PE_Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Permit_Escorts] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Escorts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Escorts] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Escorts] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Escorts] TO [public]
GO
