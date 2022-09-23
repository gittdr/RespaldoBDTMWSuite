CREATE TABLE [dbo].[TMI_ImagingRecords]
(
[flat_file_record] [varchar] (820) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iol_id] [int] NULL,
[ir_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMI_ImagingRecords] TO [public]
GO
GRANT INSERT ON  [dbo].[TMI_ImagingRecords] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMI_ImagingRecords] TO [public]
GO
GRANT SELECT ON  [dbo].[TMI_ImagingRecords] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMI_ImagingRecords] TO [public]
GO
