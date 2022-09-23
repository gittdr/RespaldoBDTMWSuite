CREATE TABLE [dbo].[tripsheetselection]
(
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tss_datawindow] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tss_company_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_company_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_company_logo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tripsheet__tss_d__7EBBD7B7] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tripsheetselection] ADD CONSTRAINT [PK__tripsheetselecti__7DC7B37E] PRIMARY KEY CLUSTERED ([ord_revtype1]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tripsheetselection] TO [public]
GO
GRANT INSERT ON  [dbo].[tripsheetselection] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tripsheetselection] TO [public]
GO
GRANT SELECT ON  [dbo].[tripsheetselection] TO [public]
GO
GRANT UPDATE ON  [dbo].[tripsheetselection] TO [public]
GO
