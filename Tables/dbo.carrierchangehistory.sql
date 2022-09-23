CREATE TABLE [dbo].[carrierchangehistory]
(
[cch_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[cch_orig_car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cch_new_car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cch_reason_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cch_updatedt] [datetime] NULL CONSTRAINT [df_carrierchangehistory] DEFAULT (getdate()),
[cch_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierchangehistory] ADD CONSTRAINT [pk_carrierchangehistory_cch_id] PRIMARY KEY CLUSTERED ([cch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierchangehistory_ord_hdrnumber] ON [dbo].[carrierchangehistory] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierchangehistory] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierchangehistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierchangehistory] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierchangehistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierchangehistory] TO [public]
GO
