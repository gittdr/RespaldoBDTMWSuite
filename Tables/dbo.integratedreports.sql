CREATE TABLE [dbo].[integratedreports]
(
[ir_id] [int] NOT NULL,
[ir_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_source] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_dwobj] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_psr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_syntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_reportlist] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ir_reportlist] DEFAULT ('N'),
[ir_messagelist] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ir_messagelist] DEFAULT ('N'),
[ir_DEFAULT_drv_email] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_DEFAULT_trc_email] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_DEFAULT_car_email] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_DEFAULT_other_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_DEFAULTsubject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_transaction] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ir_created_by_form_design] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ir_created_by_form_design] DEFAULT ('N'),
[ir_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_reportserviceaddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_reportservicereportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_reportserviceattachmenttype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_webreporturl] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_reportintegrated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_invoicelist] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_invoicebehaveas] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_settle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_asset_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_asset_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_asset_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_asset_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreports] ADD CONSTRAINT [PK_integratedreports] PRIMARY KEY NONCLUSTERED ([ir_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreports] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreports] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integratedreports] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreports] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreports] TO [public]
GO
