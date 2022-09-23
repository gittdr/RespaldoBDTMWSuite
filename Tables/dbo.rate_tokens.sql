CREATE TABLE [dbo].[rate_tokens]
(
[rt_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[rt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rt_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NULL CONSTRAINT [df_rate_tokens_updated] DEFAULT (getdate()),
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_quantity] [float] NULL,
[rt_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rate_tokens] ADD CONSTRAINT [pk_rate_tokens_rt_id] PRIMARY KEY CLUSTERED ([rt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_rate_tokens_lgh_number] ON [dbo].[rate_tokens] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rate_tokens] TO [public]
GO
GRANT INSERT ON  [dbo].[rate_tokens] TO [public]
GO
GRANT REFERENCES ON  [dbo].[rate_tokens] TO [public]
GO
GRANT SELECT ON  [dbo].[rate_tokens] TO [public]
GO
GRANT UPDATE ON  [dbo].[rate_tokens] TO [public]
GO
