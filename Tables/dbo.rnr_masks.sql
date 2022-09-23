CREATE TABLE [dbo].[rnr_masks]
(
[rnrm_id] [int] NOT NULL IDENTITY(1, 1),
[prq_id] [int] NOT NULL,
[rnrm_seq] [int] NOT NULL,
[rnrm_mask] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[corapr_id] [int] NULL CONSTRAINT [DF__rnr_masks__corap__64A6666C] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rnr_masks] ADD CONSTRAINT [pk_rnrm_id] PRIMARY KEY CLUSTERED ([rnrm_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rnr_masks] ADD CONSTRAINT [FK_rnr_masks_Process_Requirements] FOREIGN KEY ([prq_id]) REFERENCES [dbo].[Process_Requirements] ([prq_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[rnr_masks] TO [public]
GO
GRANT INSERT ON  [dbo].[rnr_masks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[rnr_masks] TO [public]
GO
GRANT SELECT ON  [dbo].[rnr_masks] TO [public]
GO
GRANT UPDATE ON  [dbo].[rnr_masks] TO [public]
GO
