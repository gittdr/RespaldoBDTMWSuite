CREATE TABLE [dbo].[dvusergroups]
(
[dug_id] [int] NOT NULL IDENTITY(1, 1),
[dvg_group] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dvusergro__usr_t__11E32137] DEFAULT ('U')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvusergroups] ADD CONSTRAINT [PK__dvusergroups__0FFAD8C5] PRIMARY KEY CLUSTERED ([dug_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dvug_altidx] ON [dbo].[dvusergroups] ([dvg_group]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvusergroups] ADD CONSTRAINT [FK__dvusergro__dvg_g__10EEFCFE] FOREIGN KEY ([dvg_group]) REFERENCES [dbo].[dvgroups] ([dvg_group]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT DELETE ON  [dbo].[dvusergroups] TO [public]
GO
GRANT INSERT ON  [dbo].[dvusergroups] TO [public]
GO
GRANT SELECT ON  [dbo].[dvusergroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[dvusergroups] TO [public]
GO
