CREATE TABLE [dbo].[branch]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brn_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_add1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_add2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_city] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_state_c] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_country_c] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_tax_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_primary_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_phone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_arcurrency] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_niwoid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_hourlyrate] [money] NULL,
[brn_dailyguarenteedhours] [money] NULL,
[brn_periodguarenteedhours] [money] NULL,
[brn_comparisonflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_zip2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_city2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_country2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_website] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_billinginfo] [varchar] (4099) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_add1_2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_add2_2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_payto] DEFAULT ('UNKNOWN'),
[brn_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_actg_type] DEFAULT ('N'),
[brn_legalentity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_legalentity] DEFAULT ('UNK'),
[brn_stlcalc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_stlcalc] DEFAULT ('L'),
[brn_acctg_prefix] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_leadbasis] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_datebasis] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_bookingterminal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_brn_bookingterminal] DEFAULT ('Y'),
[brn_executingterminal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_brn_executingterminal] DEFAULT ('N'),
[def_bookingterminal_tariff] [int] NOT NULL CONSTRAINT [df_def_bookingterminal_tariff] DEFAULT (0),
[max_bookingterminal_tariff] [int] NOT NULL CONSTRAINT [df_max_bookingterminal_tariff] DEFAULT (0),
[def_executingterminal_tariff] [int] NOT NULL CONSTRAINT [df_def_executingterminal_tariff] DEFAULT (0),
[max_executingterminal_tariff] [int] NOT NULL CONSTRAINT [df_max_executingterminal_tariff] DEFAULT (0),
[brn_retired] [int] NOT NULL CONSTRAINT [df_brn_retired] DEFAULT (0),
[brn_parent] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_brn_parent] DEFAULT ('UNKNOWN'),
[brn_orgtype1] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_orgtype2] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_orgtype3] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_hrs_dbl_time] [money] NULL,
[brn_timestamp] [timestamp] NULL,
[brn_firm_appt_value] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_executingterminal_protect] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_lastpayrollperiod] [datetime] NOT NULL CONSTRAINT [DF_brn_lastpayrollperiod] DEFAULT ('19500101'),
[brn_lastpayroll_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_lastpayroll_closed] DEFAULT ('N'),
[brn_lastpayroll_transferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_lastpayroll_transferred] DEFAULT ('N'),
[brn_payroll_fullgeneration_complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_payroll_fullgeneration_complete] DEFAULT ('N'),
[brn_transmitpayroll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_transmitpayroll] DEFAULT ('N'),
[brn_payroll_endday] [smallint] NOT NULL CONSTRAINT [DF_brn_payroll_endday] DEFAULT ((0)),
[brn_payroll_fullgeneration_date] [datetime] NOT NULL CONSTRAINT [DF_brn_payroll_fullgeneration_date] DEFAULT ('19500101'),
[brn_payroll_approveremail] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_timeoffbetweenduty] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_brn_timeoffbetweenduty] DEFAULT ((10)),
[brn_free_stop_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_geo_process_oo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_geo_send_oo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_geo_process] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_geo_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_readytoclose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_readytoclose] DEFAULT ('N'),
[brn_do_not_transfer_payroll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_do_not_transfer_payroll] DEFAULT ('Y'),
[brn_ident] [int] NOT NULL IDENTITY(1, 1),
[RatingType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__branch__RatingTy__01342303] DEFAULT ('BUY'),
[brn_paypartialclose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_brn_paypartialclose] DEFAULT ('N'),
[cc_reOpenDate] [datetime] NULL,
[cc_OK_ToReOpen] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_NextPayrollPeriod] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_branch_rowsec] ON [dbo].[branch]
FOR DELETE
AS BEGIN

	SET NOCOUNT ON 

	DELETE	RowSecColumnValues 
	FROM	RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
			deleted d_brn
	WHERE	rsc.rsc_column_name in	(	'trc_branch',
										'trl_branch',
										'mpp_branch',
										'car_branch',
										'tpr_branch',
										'ord_broker',
										'ord_booked_revtype1',
										'cmp_bookingterminal'
									)
			AND rscv.rscv_value = d_brn.brn_id
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecRowColumnValues rsrcv
										INNER JOIN RowSecColumnValues rscv on rscv.rscv_id = rsrcv.rscv_id
										INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
										deleted d_brn
								WHERE	rscv.rscv_value = d_brn.brn_id
							)		


END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_branch_rowsec] ON [dbo].[branch]
FOR INSERT, UPDATE

AS BEGIN
	SET NOCOUNT ON 

	IF UPDATE(brn_id) BEGIN
		DELETE	RowSecColumnValues 
		FROM	RowSecColumnValues rscv
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id
				INNER JOIN deleted d_brn on d_brn.brn_id = rscv.rscv_value
		WHERE	rsc.rsc_column_name in	(	'trc_branch',
											'trl_branch',
											'mpp_branch',
											'car_branch',
											'tpr_branch',
											'ord_broker',
											'ord_booked_revtype1',
											'cmp_bookingterminal'
										)
				AND NOT EXISTS	(	SELECT	*
									FROM	RowSecRowColumnValues rsrcv
											INNER JOIN RowSecColumnValues rscv on rscv.rscv_id = rsrcv.rscv_id
											INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
											deleted d_brn
									WHERE	rscv.rscv_value = d_brn.brn_id
								)		

		INSERT RowSecColumnValues	(
			rscv_description,
			rsc_id,
			rscv_value
		)
		SELECT	left(i_brn.brn_name, 20),
				rsc.rsc_id,
				i_brn.brn_id
		FROM	inserted i_brn,
				RowSecColumns rsc
		WHERE	rsc.rsc_column_name in	(	'trc_branch',
											'trl_branch',
											'mpp_branch',
											'car_branch',
											'tpr_branch',
											'ord_broker',
											'ord_booked_revtype1',
											'cmp_bookingterminal'
										)
				AND NOT EXISTS	(	SELECT	*
									FROM	RowSecColumnValues rscv_inner
									WHERE	rscv_inner.rsc_ID = rsc.rsc_ID
											AND rscv_inner.rscv_Value = i_brn.brn_id
								)

	END
	ELSE IF UPDATE(brn_name) BEGIN
		UPDATE	RowSecColumnValues
		SET		rscv_description = left(i_brn.brn_name, 20)
		FROM	RowSecColumnValues rscv
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
				inserted i_brn
		WHERE	rsc.rsc_column_name in	(	'trc_branch',
											'trl_branch',
											'mpp_branch',
											'car_branch',
											'tpr_branch',
											'ord_broker',
											'ord_booked_revtype1',
											'cmp_bookingterminal'
										)
				and rscv.rscv_value = i_brn.brn_id
	END
END
	
GO
ALTER TABLE [dbo].[branch] ADD CONSTRAINT [branch_chk_RatingType] CHECK (([RatingType]='BUY' OR [RatingType]='SELL'))
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_branch] ON [dbo].[branch] ([brn_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_branch_timestamp] ON [dbo].[branch] ([brn_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch] TO [public]
GO
GRANT INSERT ON  [dbo].[branch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[branch] TO [public]
GO
GRANT SELECT ON  [dbo].[branch] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch] TO [public]
GO
