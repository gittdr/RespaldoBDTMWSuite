CREATE TABLE [dbo].[traileralarmdetail]
(
[tad_id] [int] NOT NULL IDENTITY(1, 1),
[tch_id] [int] NOT NULL,
[tad_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tadr_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[traileralarmdetail] ADD CONSTRAINT [tad_pk] PRIMARY KEY CLUSTERED ([tad_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_coveralarmdtl] ON [dbo].[traileralarmdetail] ([tch_id], [tad_id], [tadr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[traileralarmdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[traileralarmdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[traileralarmdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[traileralarmdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[traileralarmdetail] TO [public]
GO
