SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_TotalTractorExpirations] 
(
	@BeginDay datetime,
	@EndDay datetime,
	@Tractor varchar(150),
	@ExpirationCode varchar(150)= 'OUT'
)
Returns int

As

Begin	

Declare @ExpirationCount int

SELECT @ExpirationCode = Case When Left(@ExpirationCode ,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExpirationCode , ''))) + ',' Else @ExpirationCode  End

Set @ExpirationCount = 0

select @ExpirationCount = sum(EXP)
FROM
(
SELECT EXP = ISNULL((	SELECT MIN(1) 
						FROM Expiration (NOLOCK) 
						WHERE (@ExpirationCode = ',,' OR CHARINDEX(',' + RTRIM( exp_code ) + ',', @ExpirationCode) > 0) 
							AND exp_id = @Tractor and exp_idtype = 'TRC' 
							AND PlainDate BETWEEN exp_expirationdate and exp_compldate
							AND exp_expirationdate >= @BeginDay
					),0)
FROM METRICBUSINESSDAYS
WHERE PlainDate BETWEEN @BeginDay and @EndDay
) as xx

/*
While @BeginDay <> (@EndDay+1)
Begin
	Set @ExpirationCount = @ExpirationCount + IsNull((Select Min(1) from Expiration (NOLOCK) Where (@ExpirationCode = ',,' OR CHARINDEX(',' + RTRIM( exp_code ) + ',', @ExpirationCode) > 0) 
													and  
													exp_id = @Tractor and exp_idtype = 'TRC' 
													and 
													(@BeginDay between Cast(Floor(Cast(exp_expirationdate as float))as smalldatetime) and Cast(Floor(Cast(exp_compldate as float))as smalldatetime))),0)


	Set @BeginDay = @BeginDay + 1
End
*/
Return @ExpirationCount
End

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_TotalTractorExpirations] TO [public]
GO
