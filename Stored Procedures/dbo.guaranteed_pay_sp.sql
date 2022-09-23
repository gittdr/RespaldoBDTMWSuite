SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[guaranteed_pay_sp] (
	@asgn_id		VARCHAR(13),
	@asgn_type		VARCHAR(6),
	@pyh_payperiod	DATETIME,
	@taxable	MONEY)
AS
BEGIN
	DECLARE	
		@mpp_type1		VARCHAR(6),
		@mpp_status		VARCHAR(6),
		@mpp_hiredate	DATETIME,
		@mpp_company	VARCHAR(6),
		@region			VARCHAR(8),
		@week			INTEGER,
		@pyt_itemcode	VARCHAR(6),
		@newhire_pyt	VARCHAR(6),
		@newhire		MONEY,
		@newhire_s		INTEGER,
		@newhire_e		INTEGER,
		@training_pyt	VARCHAR(6),
		@training		MONEY,
		@training_s		INTEGER,
		@training_e		INTEGER,
		@guarantee_pyt	VARCHAR(6),
		@guarantee		MONEY,
		@guarantee_s	INTEGER,	
		@guarantee_e	INTEGER,	
		@e_newhire		MONEY,
		@e_newhire_s	INTEGER,
		@e_newhire_e	INTEGER,
		@e_training		MONEY,
		@e_training_s	INTEGER,
		@e_training_e	INTEGER,
		@e_guarantee	MONEY,
		@e_guarantee_s	INTEGER,	
		@e_guarantee_e	INTEGER,	
		@mw_newhire		MONEY,
		@mw_newhire_s	INTEGER,
		@mw_newhire_e	INTEGER,
		@mw_training	MONEY,
		@mw_training_s	INTEGER,
		@mw_training_e	INTEGER,
		@mw_guarantee	MONEY,
		@mw_guarantee_s	INTEGER,	
		@mw_guarantee_e	INTEGER,	
		@s_newhire		MONEY,
		@s_newhire_s	INTEGER,
		@s_newhire_e	INTEGER,
		@s_training		MONEY,
		@s_training_s	INTEGER,
		@s_training_e	INTEGER,
		@s_guarantee	MONEY,
		@s_guarantee_s	INTEGER,	
		@S_guarantee_e	INTEGER,	
		@w_newhire		MONEY,
		@w_newhire_s	INTEGER,
		@w_newhire_e	INTEGER,
		@w_training		MONEY,
		@w_training_s	INTEGER,
		@w_training_e	INTEGER,
		@w_guarantee	MONEY,
		@w_guarantee_s	INTEGER,	
		@w_guarantee_e	INTEGER	,
		@amount			MONEY,
		@drv_type3		VARCHAR(6),
		@max_guarantee_weeks int

	--JLB PTS 39283 new logic to calculate end of guarantee timeframe
	IF @asgn_type = 'DRV'
	begin
		select @mpp_hiredate = mpp_hiredate
		  from manpowerprofile
		 where mpp_id = @asgn_id
		IF @mpp_hiredate >= '20070930'
			select @max_guarantee_weeks = 12
		ELSE
			select @max_guarantee_weeks = 25
		--end 39283
	end

	SELECT	@newhire_pyt = 'D516',
		@training_pyt = 'D585',
		@guarantee_pyt = 'D652',
		@e_newhire = CAST(270.00 AS MONEY),
		@e_newhire_s = 1,
		@e_newhire_e = 1,
		@e_training = CAST(350.00 AS MONEY),
		@e_training_s = 2,
		@e_training_e = 5,
		@e_guarantee = CAST(500.00 AS MONEY),
		@e_guarantee_s = 6,
		--@e_guarantee_e = 25,
		@e_guarantee_e = @max_guarantee_weeks,
		@mw_newhire = CAST(270.00 AS MONEY),
		@mw_newhire_s = 1,
		@mw_newhire_e = 1,
		@mw_training = CAST(300.00 AS MONEY),
		@mw_training_s = 2,
		@mw_training_e = 5,
		@mw_guarantee = CAST(500.00 AS MONEY),
		@mw_guarantee_s = 6,
		--@mw_guarantee_e = 25,
		@mw_guarantee_e = @max_guarantee_weeks,
		@s_newhire = CAST(300.00 AS MONEY),
		@s_newhire_s = 1,
		@s_newhire_e = 1,
		@s_training = CAST(300.00 AS MONEY),
		@s_training_s = 2,
		@s_training_e = 4,
		@s_guarantee = CAST(500.00 AS MONEY),
		@s_guarantee_s = 5,
		--@s_guarantee_e = 25,
		@s_guarantee_e = @max_guarantee_weeks,
		@w_newhire = CAST(300.00 AS MONEY),
		@w_newhire_s = 1,
		@w_newhire_e = 1,
		@w_training = CAST(300.00 AS MONEY),
		@w_training_s = 2,
		@w_training_e = 4,
		@w_guarantee = CAST(500.00 AS MONEY),
		@w_guarantee_s = 5,
		--@w_guarantee_e = 25
		@w_guarantee_e = @max_guarantee_weeks


	IF @asgn_type = 'DRV'
	BEGIN
		SELECT	@mpp_type1 = mpp.mpp_type1,
				@mpp_status	= mpp.mpp_status,
				@mpp_hiredate = mpp.mpp_hiredate,
				@mpp_company = mpp.mpp_company,
				@drv_type3 = mpp_type3,
				@region = CASE
							WHEN cty.cty_state IN ('CT','DE','DC','ME','MD','MA','NH','NJ','RI','VT') THEN 'EAST'
							WHEN cty.cty_state IN ('IL','IN','IA','KS','KY','MI','MN','MO','NE','ND','OH','SD','WI','WV') THEN 'MIDWEST'
							WHEN cty.cty_state IN ('AL','AR','FL','GA','LA','MS','NC','OK','SC','TN','TX') THEN 'SOUTH'
							WHEN cty.cty_state IN ('AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY') THEN 'WEST'
							ELSE CASE
									WHEN LEFT(cty.cty_zip, 3) IN ('100','101','102','103','104','105','106','107','108','109','110','111','112','113','115','116','117','118','119','120','121','122','123','124','125','126','127','128','129','133','134','135','136','137','138','139','169','170','171','172','173','174','175','176','177','178','179','180','181','182','183','184','185','186','187','188','189','190','191','192','193','194','195','196','201','220','221','222','223','224','225','227','229','230','231','232','233','234','235','236','237','238') THEN 'EAST'
									WHEN LEFT(cty.cty_zip, 3) IN ('130','131','132','140','141','142','143','144','145','146','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168') THEN 'MIDWEST'
									WHEN LEFT(cty.cty_zip, 3) IN ('226','228','239','240','241','242','243','244','245','246','252') THEN 'SOUTH'
									ELSE 'UNKNOWN'
									END
							END
		  FROM	manpowerprofile mpp
					LEFT OUTER JOIN city cty ON mpp.mpp_city = cty.cty_code
		 WHERE	mpp_id = @asgn_id

		SELECT	@region = ISNULL(@region, 'UNKNOWN'),
				@mpp_hiredate = ISNULL(@mpp_hiredate, '19500101')

		SELECT	@week = DATEDIFF(wk, @mpp_hiredate, @pyh_payperiod) + 1

		IF @mpp_hiredate >= '20060604'
		BEGIN
			SELECT	@e_newhire = CAST(480.00 AS MONEY),
					@w_newhire = CAST(480.00 AS MONEY),
					@s_newhire = CAST(480.00 AS MONEY),
					@mw_newhire = CAST(480.00 AS MONEY),
					@e_training = CAST(400.00 AS MONEY),
					@w_training = CAST(350.00 AS MONEY),
					@s_training = CAST(350.00 AS MONEY),
					@mw_training = CAST(350.00 AS MONEY),
					@mw_training_e = 4,
					@mw_guarantee_s = 5,
					@e_training_e = 4,
					@e_guarantee_s = 5
		END
		ELSE IF @mpp_hiredate >= '20060219'
		BEGIN
			SELECT	@e_newhire = CAST(400.00 AS MONEY),
					@w_newhire = CAST(400.00 AS MONEY),
					@s_newhire = CAST(400.00 AS MONEY),
					@mw_newhire = CAST(400.00 AS MONEY),
					@mw_training_e = 4,
					@mw_guarantee_s = 5,
					@e_training_e = 4,
					@e_guarantee_s = 5

		END

		IF @mpp_hiredate >= '20050206' 
			AND @mpp_type1 = 'CBAS'
			AND @region IN ('EAST','MIDWEST','SOUTH','WEST')
			AND @week BETWEEN 1 AND @max_guarantee_weeks
			AND @mpp_status NOT IN ('OP','OTPR','OUT','SKST','SKLT','WCST','WCLT','MILIT','OFC','VACA','1VAC','2VAC')
			AND @mpp_company = 'GAUR'
		BEGIN
		SELECT	@newhire = CASE	@region
								WHEN 'EAST' THEN @e_newhire
								WHEN 'MIDWEST' THEN @mw_newhire
								WHEN 'SOUTH' THEN @s_newhire
								WHEN 'WEST' THEN @w_newhire
								END,
				@training = CASE @region
								WHEN 'EAST' THEN @e_training
								WHEN 'MIDWEST' THEN @mw_training
								WHEN 'SOUTH' THEN @s_training
								WHEN 'WEST' THEN @w_training
								END,
				@guarantee = CASE @region
								WHEN 'EAST' THEN @e_guarantee
								WHEN 'MIDWEST' THEN @mw_guarantee
								WHEN 'SOUTH' THEN @s_guarantee
								WHEN 'WEST' THEN @w_guarantee
								END,
				@newhire_s = CASE @region
								WHEN 'EAST' THEN @e_newhire_s
								WHEN 'MIDWEST' THEN @mw_newhire_s
								WHEN 'SOUTH' THEN @s_newhire_s
								WHEN 'WEST' THEN @w_newhire_s
								END,
				@newhire_e = CASE @region
								WHEN 'EAST' THEN @e_newhire_e
								WHEN 'MIDWEST' THEN @mw_newhire_e
								WHEN 'SOUTH' THEN @s_newhire_e
								WHEN 'WEST' THEN @w_newhire_e
								END,
				@training_s = CASE @region
								WHEN 'EAST' THEN @e_training_s
								WHEN 'MIDWEST' THEN @mw_training_s
								WHEN 'SOUTH' THEN @s_training_s
								WHEN 'WEST' THEN @w_training_s
								END,
				@training_e = CASE @region
								WHEN 'EAST' THEN @e_training_e
								WHEN 'MIDWEST' THEN @mw_training_e
								WHEN 'SOUTH' THEN @s_training_e
								WHEN 'WEST' THEN @w_training_e
								END,
				@guarantee_s = CASE @region
								WHEN 'EAST' THEN @e_guarantee_s
								WHEN 'MIDWEST' THEN @mw_guarantee_s
								WHEN 'SOUTH' THEN @s_guarantee_s
								WHEN 'WEST' THEN @w_guarantee_s
								END,
				@guarantee_e = CASE @region
								WHEN 'EAST' THEN @e_guarantee_e
								WHEN 'MIDWEST' THEN @mw_guarantee_e
								WHEN 'SOUTH' THEN @s_guarantee_e
								WHEN 'WEST' THEN @w_guarantee_e
								END,
				@pyt_itemcode = CASE
								WHEN @week BETWEEN @newhire_s AND @newhire_e THEN @newhire_pyt
								WHEN @week BETWEEN @training_s AND @training_e THEN @training_pyt
								WHEN @week BETWEEN @guarantee_s AND @guarantee_e THEN @guarantee_pyt
								END

			IF @pyt_itemcode = @guarantee_pyt 
			BEGIN
				IF @drv_type3 = 'TRE'
				BEGIN
					SELECT @pyt_itemcode = @training_pyt
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT	* 
								FROM	paydetail 
											INNER JOIN paytype ON paytype.pyt_itemcode = paydetail.pyt_itemcode
							   WHERE	asgn_id = @asgn_id AND
										asgn_type = @asgn_type AND
										pyh_payperiod >= DATEADD(mm, -1, @pyh_payperiod) AND
										paytype.pyt_basis = 'LGH')
					BEGIN
						SELECT	@taxable = @taxable - IsNull(sum(pyd_amount),0) 
						  FROM	paydetail
						 WHERE	asgn_id = @asgn_id AND
								asgn_type = @asgn_type AND
								pyh_payperiod = @pyh_payperiod AND
								pyt_itemcode = @pyt_itemcode
					END
					ELSE
					BEGIN				
						SELECT @pyt_itemcode = @training_pyt
					END
				END
			END
			
			SELECT  @amount = CASE
								WHEN @pyt_itemcode = @newhire_pyt THEN @newhire
								WHEN @pyt_itemcode = @training_pyt THEN @training
								WHEN @pyt_itemcode = @guarantee_pyt THEN CASE 
																			WHEN @taxable > @guarantee THEN 0
																			ELSE @guarantee - @taxable	
																			END	
								END
						
		END
	END

	If @amount > 500
	 BEGIN
	  	Select @amount = 500
	 END

	SELECT IsNull(@pyt_itemcode, 'UNK'), @amount
END

GO
GRANT EXECUTE ON  [dbo].[guaranteed_pay_sp] TO [public]
GO
