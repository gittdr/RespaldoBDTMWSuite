CREATE TABLE [dbo].[safetyClaims]
(
[scl_Ident] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[scl_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scl_suffix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[srp_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scl_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scl_claimItem] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scl_claimQuantity] [float] NULL,
[scl_claimUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scl_claimRateUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scl_claimRate] [money] NULL,
[scl_subtotal] [money] NULL,
[scl_totalCharge] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[safetyClaims] ADD CONSTRAINT [pk_scl_ID] PRIMARY KEY CLUSTERED ([scl_Ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[safetyClaims] TO [public]
GO
GRANT INSERT ON  [dbo].[safetyClaims] TO [public]
GO
GRANT REFERENCES ON  [dbo].[safetyClaims] TO [public]
GO
GRANT SELECT ON  [dbo].[safetyClaims] TO [public]
GO
GRANT UPDATE ON  [dbo].[safetyClaims] TO [public]
GO
