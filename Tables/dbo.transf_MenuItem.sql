CREATE TABLE [dbo].[transf_MenuItem]
(
[menu_id] [int] NOT NULL IDENTITY(1, 1),
[menu_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_transf_MenuItem_sequence] DEFAULT ('0000000000'),
[def_text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Menu_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Menu_program] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yn_system] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[target_frame] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[img_file] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_menu_id] [int] NULL,
[yn_main_menu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_MenuItem_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL,
[meu_branch_list] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[meu_group_list] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[dt_transf_MenuItem] ON [dbo].[transf_MenuItem] FOR DELETE AS 
/* EXECUTE timerins "dt_transf_MenuItem", "START" */
set nocount on

	delete transf_MenuGroups 
		from transf_MenuGroups g, deleted d
		where g.menu_id = d.menu_id

	delete transf_MenuBranches 
		from transf_MenuBranches b, deleted d
		where b.menu_id = d.menu_id
return
SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[transf_MenuItem] ADD CONSTRAINT [PK_transf_MenuItem] PRIMARY KEY CLUSTERED ([menu_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_MenuItem] ADD CONSTRAINT [UK_transf_MenuItem_Menu_name] UNIQUE NONCLUSTERED ([menu_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_MenuItem] ADD CONSTRAINT [UK_transf_MenuItem_sequence] UNIQUE NONCLUSTERED ([sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_MenuItem] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_MenuItem] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_MenuItem] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_MenuItem] TO [public]
GO
