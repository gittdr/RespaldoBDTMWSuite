CREATE TABLE [dbo].[EERESPONSE]
(
[eer_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[eer_Date] [datetime] NULL,
[eer_MppOrEeID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_Comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_ReviewedBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_ReviewedByDate] [datetime] NULL,
[eer_respondentis] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_nmstct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_city] [int] NULL,
[eer_state] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_phone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_phone2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_number1] [money] NULL,
[eer_number2] [money] NULL,
[eer_number3] [money] NULL,
[eer_number4] [money] NULL,
[eer_number5] [money] NULL,
[eer_date1] [datetime] NULL,
[eer_date2] [datetime] NULL,
[eer_date3] [datetime] NULL,
[eer_date4] [datetime] NULL,
[eer_date5] [datetime] NULL,
[eer_ResponseType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_ResponseType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_ResponseType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eer_ResponseType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_EERESPONSE_timestamp] ON [dbo].[EERESPONSE] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_eerID] ON [dbo].[EERESPONSE] ([eer_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srptypekey] ON [dbo].[EERESPONSE] ([srp_ID], [eer_MppOrEeID], [eer_Date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EERESPONSE] TO [public]
GO
GRANT INSERT ON  [dbo].[EERESPONSE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EERESPONSE] TO [public]
GO
GRANT SELECT ON  [dbo].[EERESPONSE] TO [public]
GO
GRANT UPDATE ON  [dbo].[EERESPONSE] TO [public]
GO
