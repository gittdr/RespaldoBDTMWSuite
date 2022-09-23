CREATE TABLE [dbo].[ltl_reweigh]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[evt_number] [int] NULL,
[count] [decimal] (10, 2) NULL,
[countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pallet] [float] NULL,
[palletunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [float] NULL,
[weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[volume] [float] NULL,
[volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [float] NULL,
[lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [float] NULL,
[heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [float] NULL,
[widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_rate_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ltl_rewei__proce__245BFECB] DEFAULT ('N'),
[processed_date] [datetime] NULL,
[processed_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_reweigh] ADD CONSTRAINT [PK__ltl_rewe__3213E83FF07218F0] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [reweight_evtnum] ON [dbo].[ltl_reweigh] ([evt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_reweigh] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_reweigh] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_reweigh] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_reweigh] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_reweigh] TO [public]
GO
