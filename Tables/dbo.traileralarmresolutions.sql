CREATE TABLE [dbo].[traileralarmresolutions]
(
[tadr_id] [int] NOT NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acm_system] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tadr_alarmtext] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tadr_original_tad_id] [int] NULL,
[tadr_date] [datetime] NOT NULL,
[tadr_user] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tadr_resolution] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tadr_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[traileralarmresolutions] ADD CONSTRAINT [tadr_pk] PRIMARY KEY CLUSTERED ([tadr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tadr_activeforunit] ON [dbo].[traileralarmresolutions] ([tadr_active], [acm_system], [trl_id], [tadr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[traileralarmresolutions] TO [public]
GO
GRANT INSERT ON  [dbo].[traileralarmresolutions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[traileralarmresolutions] TO [public]
GO
GRANT SELECT ON  [dbo].[traileralarmresolutions] TO [public]
GO
GRANT UPDATE ON  [dbo].[traileralarmresolutions] TO [public]
GO
