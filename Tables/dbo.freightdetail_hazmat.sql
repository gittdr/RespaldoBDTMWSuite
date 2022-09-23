CREATE TABLE [dbo].[freightdetail_hazmat]
(
[ord_hdrnumber] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[fgt_number] [int] NOT NULL,
[HazClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HazPackaging] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HazUNCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [dc_freightdetail_hazmat_CreateDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateDate] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ord_stp_fgt] ON [dbo].[freightdetail_hazmat] ([ord_hdrnumber], [stp_number], [fgt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[freightdetail_hazmat] TO [public]
GO
GRANT INSERT ON  [dbo].[freightdetail_hazmat] TO [public]
GO
GRANT SELECT ON  [dbo].[freightdetail_hazmat] TO [public]
GO
GRANT UPDATE ON  [dbo].[freightdetail_hazmat] TO [public]
GO
