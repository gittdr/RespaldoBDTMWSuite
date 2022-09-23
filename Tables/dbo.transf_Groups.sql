CREATE TABLE [dbo].[transf_Groups]
(
[group_id] [int] NOT NULL IDENTITY(1, 1),
[group_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_transf_Groups_status] DEFAULT ('Active'),
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_Groups_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[dt_transf_groups] ON [dbo].[transf_Groups] FOR DELETE AS 
/* EXECUTE timerins "dt_transf_groups", "START" */
set nocount on

	delete transf_MenuGroups 
		from transf_MenuGroups m, deleted d
		where m.group_id = d.group_id

	delete transf_UserGroups 
		from transf_UserGroups u, deleted d
		where u.group_id = d.group_id
return
SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[transf_Groups] ADD CONSTRAINT [PK_transf_Groups] PRIMARY KEY CLUSTERED ([group_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_Groups] ADD CONSTRAINT [UK_transf_Groups_group_name] UNIQUE NONCLUSTERED ([group_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_Groups] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_Groups] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_Groups] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_Groups] TO [public]
GO
