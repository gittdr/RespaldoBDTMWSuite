CREATE TABLE [dbo].[ttrfilter]
(
[ttrf_number] [int] NOT NULL,
[ttr_number] [int] NOT NULL,
[ttrd_terminusnbr] [smallint] NOT NULL,
[ttrf_filter] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_ttrtermlvl] ON [dbo].[ttrfilter] ([ttr_number], [ttrd_terminusnbr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttrfilter] TO [public]
GO
GRANT INSERT ON  [dbo].[ttrfilter] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttrfilter] TO [public]
GO
GRANT SELECT ON  [dbo].[ttrfilter] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttrfilter] TO [public]
GO
