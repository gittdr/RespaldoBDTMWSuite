CREATE TABLE [dbo].[FuelGPPayableGLValidation]
(
[FuelGPPayableGLValidationId] [int] NOT NULL IDENTITY(1, 1),
[GreatPlainsServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GreatPlainsDatabase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GeneralLedgerNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NULL CONSTRAINT [df_FuelGPPayableGLValidationLastUpdateDate] DEFAULT (getdate()),
[LastUpdateBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_FuelGPPayableGLValidationLastUpdateBy] DEFAULT (suser_name()),
[CreatedDate] [datetime] NULL CONSTRAINT [df_FuelGPPayableGLValidationCreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_FuelGPPayableGLValidationCreatedBy] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelGPPayableGLValidation] ADD CONSTRAINT [ix_FuelGPPayableGLValidation_FuelGPPayableGLValidationId] PRIMARY KEY CLUSTERED ([FuelGPPayableGLValidationId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelGPPayableGLValidation] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelGPPayableGLValidation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelGPPayableGLValidation] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelGPPayableGLValidation] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelGPPayableGLValidation] TO [public]
GO
