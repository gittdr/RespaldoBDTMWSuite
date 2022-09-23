CREATE TABLE [dbo].[ordercarrierrates]
(
[ocr_id] [int] NOT NULL IDENTITY(1, 1),
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ocr_preferred_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_tenderstatus] [int] NULL,
[ocr_response] [int] NULL,
[err_batch] [int] NULL,
[ocr_created_date] [datetime] NULL,
[ocr_tenderdate] [datetime] NULL,
[ocr_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_carrier_lane_maxloads] [smallint] NULL,
[ocr_rate] [money] NULL,
[ocr_charge] [money] NULL,
[ocr_cur_commit_count] [smallint] NULL,
[ocr_edi204_accrej_ratio] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NOT NULL CONSTRAINT [DF_ordercarrierrates_Updatedt] DEFAULT (getdate()),
[ocr_millassigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_rate_error] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ocr_rate_error_desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_billedweight] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordercarrierrates] ADD CONSTRAINT [PK_ordercarrierrates_ocr_id] PRIMARY KEY CLUSTERED ([ocr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ordercarrierrates_ord_number] ON [dbo].[ordercarrierrates] ([ord_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordercarrierrates] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercarrierrates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercarrierrates] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercarrierrates] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercarrierrates] TO [public]
GO
