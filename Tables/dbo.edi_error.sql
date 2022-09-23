CREATE TABLE [dbo].[edi_error]
(
[err_id] [int] NOT NULL IDENTITY(1, 1),
[err_GSControlNo] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[err_STcontrolNo] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_layer] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[err_errorCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_segmentErrorCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_segmentID] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_segmentPosition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_elementPosition] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_elementReference] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_elementErrorCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_baddata] [varchar] (99) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_pronumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_docid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_datetime] [datetime] NOT NULL CONSTRAINT [DF__edi_error__err_d__519A7DDF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_error] ADD CONSTRAINT [PK__edi_erro__ACE9FA5E6D2F32AB] PRIMARY KEY CLUSTERED ([err_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_error] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_error] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_error] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_error] TO [public]
GO
