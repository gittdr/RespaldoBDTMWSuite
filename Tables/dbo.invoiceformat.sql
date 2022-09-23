CREATE TABLE [dbo].[invoiceformat]
(
[ift_id] [int] NOT NULL,
[ift_dwname] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ift_dwdesc] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ift_sequence] [smallint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoiceformat] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceformat] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceformat] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceformat] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceformat] TO [public]
GO
