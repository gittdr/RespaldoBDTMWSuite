CREATE TABLE [dbo].[eventdefaults]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evd_seq] [int] NOT NULL,
[evd_eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [i_evd1] ON [dbo].[eventdefaults] ([cmp_id], [evd_seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventdefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[eventdefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventdefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[eventdefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventdefaults] TO [public]
GO
