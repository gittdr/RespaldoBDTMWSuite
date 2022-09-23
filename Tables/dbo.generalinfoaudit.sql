CREATE TABLE [dbo].[generalinfoaudit]
(
[gi_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gi_datein] [datetime] NOT NULL,
[gi_string1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string4] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_integer1] [int] NULL,
[gi_integer2] [int] NULL,
[gi_integer3] [int] NULL,
[gi_integer4] [int] NULL,
[gi_date1] [datetime] NULL,
[gi_date2] [datetime] NULL,
[gi_appid] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_id] [int] NOT NULL IDENTITY(1, 1),
[gi_updateddate] [datetime] NULL CONSTRAINT [DF_generalinfoaudit_gi_updateddate] DEFAULT (getdate()),
[gi_updateduser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_generalinfoaudit_gi_updateduser] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[generalinfoaudit] ADD CONSTRAINT [PK__generalinfoaudit__48BEEE62] PRIMARY KEY CLUSTERED ([gi_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[generalinfoaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[generalinfoaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[generalinfoaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[generalinfoaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[generalinfoaudit] TO [public]
GO
