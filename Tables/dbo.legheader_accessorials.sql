CREATE TABLE [dbo].[legheader_accessorials]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[accessorial_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (18, 4) NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_date] [datetime] NULL,
[FromPayDetail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromInvoiceDetail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_accessorials] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_accessorials] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_accessorials] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_accessorials] TO [public]
GO
