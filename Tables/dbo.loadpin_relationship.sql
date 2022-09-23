CREATE TABLE [dbo].[loadpin_relationship]
(
[lpr_id] [int] NOT NULL IDENTITY(1, 1),
[lpr_cust_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lpr_ship_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lpr_account] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lpr_pin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loadpin_relationship] ADD CONSTRAINT [pk_loadpin] PRIMARY KEY CLUSTERED ([lpr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadpin_relationship] TO [public]
GO
GRANT INSERT ON  [dbo].[loadpin_relationship] TO [public]
GO
GRANT REFERENCES ON  [dbo].[loadpin_relationship] TO [public]
GO
GRANT SELECT ON  [dbo].[loadpin_relationship] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadpin_relationship] TO [public]
GO
