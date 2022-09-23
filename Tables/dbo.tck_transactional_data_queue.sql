CREATE TABLE [dbo].[tck_transactional_data_queue]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[status] [int] NOT NULL,
[packet] [varchar] (1280) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_added] [datetime] NULL,
[dt_processed] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [StatusIndex] ON [dbo].[tck_transactional_data_queue] ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tck_transactional_data_queue] TO [public]
GO
GRANT INSERT ON  [dbo].[tck_transactional_data_queue] TO [public]
GO
GRANT SELECT ON  [dbo].[tck_transactional_data_queue] TO [public]
GO
GRANT UPDATE ON  [dbo].[tck_transactional_data_queue] TO [public]
GO
