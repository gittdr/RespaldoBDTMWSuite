CREATE TABLE [dbo].[dx_EDI990State]
(
[est_Ident] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[est_Order_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[est_DocumentNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[est_SourceDate] [datetime] NOT NULL,
[trp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[est_990State] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_EDI990State] ADD CONSTRAINT [PK_dx_EDI990State] PRIMARY KEY CLUSTERED ([est_Ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_EDI990State] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_EDI990State] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_EDI990State] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_EDI990State] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_EDI990State] TO [public]
GO
