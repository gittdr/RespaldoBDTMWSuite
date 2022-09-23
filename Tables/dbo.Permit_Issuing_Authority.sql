CREATE TABLE [dbo].[Permit_Issuing_Authority]
(
[PIA_ID] [int] NOT NULL IDENTITY(1, 1),
[PIA_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PIA_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[st_abbr] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_code] [int] NULL,
[cty_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_ContactPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_ContactFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_ContactEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Website] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_FTPAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_FTPLogin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_FTPPassword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Contact2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Contact2Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Contact2Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Contact2Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Mail_Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Mail_Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Mail_City] [int] NULL,
[PIA_Mail_City_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIA_Mail_Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pia_max_gvw] [int] NULL,
[pia_timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Issuing_Authority] ADD CONSTRAINT [PK_Permit_Issuing_Entity] PRIMARY KEY CLUSTERED ([PIA_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Issuing_Authority] ADD CONSTRAINT [IX_Permit_Issuing_Authority_PIA_Name] UNIQUE NONCLUSTERED ([PIA_Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Permit_Issuing_Authority] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Issuing_Authority] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Issuing_Authority] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Issuing_Authority] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Issuing_Authority] TO [public]
GO
