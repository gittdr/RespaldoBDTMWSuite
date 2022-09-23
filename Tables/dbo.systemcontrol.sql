CREATE TABLE [dbo].[systemcontrol]
(
[sys_controlid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sys_controlnumber] [int] NOT NULL,
[sys_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_alternateparm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sys_locked] [int] NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[systemcontrol] ADD CONSTRAINT [AutoPK_systemcontrol] PRIMARY KEY CLUSTERED ([sys_controlid], [sys_alternateparm]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_sysid] ON [dbo].[systemcontrol] ([sys_controlid], [sys_alternateparm]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[systemcontrol] TO [public]
GO
GRANT INSERT ON  [dbo].[systemcontrol] TO [public]
GO
GRANT REFERENCES ON  [dbo].[systemcontrol] TO [public]
GO
GRANT SELECT ON  [dbo].[systemcontrol] TO [public]
GO
GRANT UPDATE ON  [dbo].[systemcontrol] TO [public]
GO
