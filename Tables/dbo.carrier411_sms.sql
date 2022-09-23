CREATE TABLE [dbo].[carrier411_sms]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[sms_cas_docket_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sms_insp_total] [int] NULL,
[sms_driver_insp_total] [int] NULL,
[sms_driver_oos_insp_total] [int] NULL,
[sms_vehicle_insp_total] [int] NULL,
[sms_vehicle_oos_insp_total] [int] NULL,
[sms_fit_last] [datetime] NULL,
[sms_safe_fit] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_basic_last] [datetime] NULL,
[sms_ins_other_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_ins_other_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_prcnt] [decimal] (4, 1) NULL,
[sms_unsafe_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_inspect] [int] NULL,
[sms_unsafe_score] [decimal] (5, 2) NULL,
[sms_fatig_prcnt] [decimal] (4, 1) NULL,
[sms_fatig_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_inspect] [int] NULL,
[sms_fatig_score] [decimal] (5, 2) NULL,
[sms_fit_prcnt] [decimal] (4, 1) NULL,
[sms_fit_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_inspect] [int] NULL,
[sms_fit_score] [decimal] (5, 2) NULL,
[sms_cntrl_prcnt] [decimal] (4, 1) NULL,
[sms_cntrl_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_inspect] [int] NULL,
[sms_cntrl_score] [decimal] (5, 2) NULL,
[sms_veh_prcnt] [decimal] (4, 1) NULL,
[sms_veh_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_inspect] [int] NULL,
[sms_veh_score] [decimal] (5, 2) NULL,
[sms_cargo_prcnt] [decimal] (4, 1) NULL,
[sms_cargo_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cargo_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cargo_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cargo_inspect] [int] NULL,
[sms_cargo_score] [decimal] (5, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411_sms] ADD CONSTRAINT [pk_sms_cas_docket_number] PRIMARY KEY CLUSTERED ([sms_cas_docket_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411_sms] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411_sms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411_sms] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411_sms] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411_sms] TO [public]
GO
