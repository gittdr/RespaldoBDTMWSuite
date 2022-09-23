CREATE TABLE [dbo].[integratedreportkitusers]
(
[irk_id] [int] NOT NULL,
[usr_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportkitusers] ADD CONSTRAINT [pk_integratedreportkitusers] PRIMARY KEY CLUSTERED ([irk_id], [usr_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportkitusers] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportkitusers] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportkitusers] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportkitusers] TO [public]
GO
