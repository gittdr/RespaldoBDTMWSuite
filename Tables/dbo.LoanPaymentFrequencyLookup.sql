CREATE TABLE [dbo].[LoanPaymentFrequencyLookup]
(
[Id] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoanPaymentFrequencyLookup] ADD CONSTRAINT [PK_dbo.LoanPaymentFrequencyLookup] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
