CREATE TABLE [dbo].[InspectionsDamage]
(
[ind_id] [int] NOT NULL IDENTITY(1, 1),
[ins_id] [int] NOT NULL,
[ind_type] [int] NOT NULL,
[ind_area] [int] NOT NULL,
[ind_severity] [int] NOT NULL,
[ind_createddate] [datetime] NULL,
[ind_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ind_lastupdatedt] [datetime] NULL,
[ind_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ind_errormessage] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ind_dmg_desc] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InspectionsDamage] ADD CONSTRAINT [pk_indid] PRIMARY KEY CLUSTERED ([ind_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InspectionsDamage] TO [public]
GO
GRANT INSERT ON  [dbo].[InspectionsDamage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[InspectionsDamage] TO [public]
GO
GRANT SELECT ON  [dbo].[InspectionsDamage] TO [public]
GO
GRANT UPDATE ON  [dbo].[InspectionsDamage] TO [public]
GO
