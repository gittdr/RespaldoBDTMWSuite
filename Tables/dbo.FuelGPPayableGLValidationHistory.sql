CREATE TABLE [dbo].[FuelGPPayableGLValidationHistory]
(
[FuelGPPayableGLValidationHistoryId] [int] NOT NULL IDENTITY(1, 1),
[GreatPlainsServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GreatPlainsDatabase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GeneralLedgerNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NULL CONSTRAINT [df_FuelGPPayableGLValidationHistoryLastUpdateDate] DEFAULT (getdate()),
[LastUpdateBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_FuelGPPayableGLValidationHistoryLastUpdateBy] DEFAULT (suser_name()),
[CreatedDate] [datetime] NULL CONSTRAINT [df_FuelGPPayableGLValidationHistoryCreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_FuelGPPayableGLValidationHistoryCreatedBy] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelGPPayableGLValidationHistory] ADD CONSTRAINT [ix_FuelGPPayableGLValidationHistory_FuelGPPayableGLValidationHistoryId] PRIMARY KEY CLUSTERED ([FuelGPPayableGLValidationHistoryId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelGPPayableGLValidationHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelGPPayableGLValidationHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelGPPayableGLValidationHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelGPPayableGLValidationHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelGPPayableGLValidationHistory] TO [public]
GO
