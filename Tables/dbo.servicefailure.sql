CREATE TABLE [dbo].[servicefailure]
(
[ord_hdrnumber] [int] NOT NULL,
[sf_sequence_number] [int] NOT NULL,
[trc_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_terminal] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_terminal] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_terminal] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sf_rescheduled_date] [datetime] NOT NULL CONSTRAINT [DF__servicefa__sf_re__10072AA1] DEFAULT (getdate()),
[sf_contacted_shipper] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_shipper_contact_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_shipper_contact_date] [datetime] NULL,
[sf_contacted_consignee] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_consignee_contact_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_consignee_contact_date] [datetime] NULL,
[sf_supervisor] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sft_cause_id] [int] NOT NULL,
[sf_cause_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sft_effect_id] [int] NOT NULL,
[sf_effect_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_investigator] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_corrective_action] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_product_release] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sf_entereddate] [datetime] NOT NULL,
[sf_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sf_carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_incident_date] [datetime] NULL,
[sf_incident_location] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_incident_number] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_shipper_contact_format] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_consignee_contact_format] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_dangerous_hazardous] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old_id1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_id1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old_id2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_id2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_shipper_rescheduled_date] [datetime] NULL,
[sf_consignee_rescheduled_date] [datetime] NULL,
[sf_results_of_follow_up] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_name_of_qit_chairperson] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_closure_date] [datetime] NULL,
[sf_deviation_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_followed_up_date] [datetime] NULL,
[sf_followed_up] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_follow_up_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[servicefailure] ADD CONSTRAINT [sf_ordhdr_seq] PRIMARY KEY CLUSTERED ([ord_hdrnumber], [sf_sequence_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[servicefailure] TO [public]
GO
GRANT INSERT ON  [dbo].[servicefailure] TO [public]
GO
GRANT SELECT ON  [dbo].[servicefailure] TO [public]
GO
GRANT UPDATE ON  [dbo].[servicefailure] TO [public]
GO
