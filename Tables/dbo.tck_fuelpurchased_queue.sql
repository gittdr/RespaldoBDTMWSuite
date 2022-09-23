CREATE TABLE [dbo].[tck_fuelpurchased_queue]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[status] [int] NOT NULL,
[packet] [varchar] (1280) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_added] [datetime] NULL,
[dt_last_updated] [datetime] NULL,
[tck_fp_que_error_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tck_fuelpurchased_queue] ADD CONSTRAINT [PK_tck_fuelpurchased_queue] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tck_fuelpurchased_queue] TO [public]
GO
GRANT INSERT ON  [dbo].[tck_fuelpurchased_queue] TO [public]
GO
GRANT SELECT ON  [dbo].[tck_fuelpurchased_queue] TO [public]
GO
GRANT UPDATE ON  [dbo].[tck_fuelpurchased_queue] TO [public]
GO
