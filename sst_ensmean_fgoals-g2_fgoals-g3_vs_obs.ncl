load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

gg                 = 9.806
pi                 = 3.14159265359
;pi                = 4.0*ATAN(1.0)
d2rad              = 0.01745329
;R0                = 6371393.0
;RADIUS            = 6371000.0
R0                 = 6371000.0
rad                = (pi/180.)
cp                 = 3996.0
p0                 = 1026.0

lev1               = (/0, -10, -20, -30, -40, -50, -60, -70, -80, -90, -100, -110, -120, -130, -140, -150, -163.8606, -192.9948, -252.0088, -354.2027, -510.9896, -731.3966, -1021.67, -1385.003, -1821.396, -2327.656, -2897.536, -3522.009, -4189.662, -4887.194, -5600/)

; plot_format        = "x11"
;plot_name          = "ts_omip_cycle6_atlantic_cycle3"
plot_name          = "sst_ensmean"
plot_color         = "ncl_default"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fin1              = addfile("/data05/linpf/FGOALS-g3/weijl_meanstate_plot/fgoals-g2/fgoals-g2.hist.198001to200512.4ensmean.timmean.r360x180.nc","r")
fin2              = addfile("/data05/linpf/FGOALS-f3/zhaobw_plot/obs/ersst.v5.1854to2018.monthly-r360x180.nc","r")
fin3              = addfile("/data05/linpf/FGOALS-g3/data/tsss_1To12-ee14d-6ensmean.r360x180.nc","r")

var1               = fin1->ts(:,0,:,:);(time, lev, lat, lon) fgoals-g2
var2               = fin2->sst((1980-1854)*12:(2005-1854)*12+11,0,:,:);ersst
var3               = fin3->ts(:,0,:,:); fgoals-g3
var4               = fin2->sst((1980-1854)*12:(2014-1854)*12+11,0,:,:);ersst


;lon               = fin1->lon
;lat               = fin1->lat

ts1               = dim_avg_n_Wrap(var1,0)
ts2               = dim_avg_n_Wrap(var2,0)
ts3               = dim_avg_n_Wrap(var3,0)
ts4               = dim_avg_n_Wrap(var4,0)

; printVarSummary(ts1)
; printVarSummary(ts2)

ts1_diff_ts2      = ts1 ; initialize  
ts1_diff_ts2      = ts1 - ts2  ; ens - obs

ts3_diff_ts2      = ts1
ts3_diff_ts2      = ts3 - ts4 ; ens-obs for different period
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lat                 = var1&lat
lon                 = var1&lon
nlat                = dimsizes(lat)
nlon                = dimsizes(lon)

dy                 = new((/nlat/),"float")
do j = 0,nlat-1
   if(j.gt.0.and.j.lt.(nlat-1))then
     dy0=abs(doubletofloat((lat(j)-lat(j-1))/2.0))
     dy1=abs(doubletofloat((lat(j+1)-lat(j))/2.0))
     dy(j)=abs((dy0+dy1)*pi*R0/180.0)
     delete(dy0)
     delete(dy1)
   end if
   if(j.eq.0)then
     dy1=abs(doubletofloat((lat(j+1)-lat(j))/2.0))
     dy(j)=abs((2.*dy1)*pi*R0/180.0)
     delete(dy1)
   end if
   if(j.eq.nlat-1)then
     dy0=abs(doubletofloat((lat(j)-lat(j-1))/2.0))
     dy(j)=abs((2.*dy0)*pi*R0/180.0)
     delete(dy0)
   end if
end do
dy!0               = "lat"
dy&lat             = lat

dx                 = new((/nlat/),"float")
do i = 0,nlat-1
   dx(i)=abs(doubletofloat(pi*R0*cos(lat(i)*d2rad)/180.0))
end do
dx!0               = "lat"
dx&lat             = lat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

area1             = new((/nlat,nlon/),"float",ts1_diff_ts2@_FillValue)

do j = 0,nlat-1
   do i = 0,nlon-1
      if(.not.ismissing(ts1_diff_ts2(j,i)))then
        area1(j,i) = dx(j)*dy(j)
      else
        area1(j,i) = ts1_diff_ts2@_FillValue
      end if
   end do
end do

area1!0            = "lat"
area1&lat          = lat
area1!1            = "lon"
area1&lon          = lon
area1@_FillValue   = ts1_diff_ts2@_FillValue

rms1                = sqrt(sum(ts1_diff_ts2*ts1_diff_ts2*area1)/sum(area1)) ;rms for fgoals-g2
rms11               = sqrt(sum(ts3_diff_ts2*ts3_diff_ts2*area1)/sum(area1)) ;rms for fgoals-g3

mean1               = sum(ts1_diff_ts2*area1)/sum(area1)
mean11              = sum(ts3_diff_ts2*area1)/sum(area1)
; print(rms1)
; print(mean1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; print(num(.not.ismissing(var1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wks  = gsn_open_wks("eps",get_script_prefix_name())
gsn_define_colormap(wks,plot_color)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot                                     = new(8,graphic)

res                                      = True

res@cnFillOn                             = True
res@cnLinesOn                            = False

res@cnLineLabelsOn                       = False
res@cnLabelMasking                       = True
res@cnLineLabelBackgroundColor           = "transparent"

res@cnInfoLabelOn                        = False
res@gsnSpreadColors                      = True

res@lbOrientation                        = "vertical"
res@lbLabelAutoStride                    = False
;res@lbBoxEndCapStyle                     = "TriangleBothEnds"
res@lbFillOpacityF                       = 1.0
res@lbLabelStride                        = 2
res@lbBoxLineColor                      = "seashell2"

; res@pmTickMarkDisplayMode                = "Always"

;res@tiYAxisString                       = "Depth (m)"

res@gsnContourNegLineDashPattern         = 1
res@gsnContourZeroLineThicknessF         = 2
res@gsnDraw                              = False
res@gsnFrame                             = False

res@cnMissingValPerimOn                  = True
res@cnMissingValFillPattern              = 3
res@cnMissingValFillColor                = "transparent"

res@tiXAxisFontHeightF                   = 0.007
res@tiYAxisFontHeightF                   = 0.007
res@tmXBLabelFontHeightF                 = 0.006
res@tmYLLabelFontHeightF                 = 0.006
res@gsnLeftStringFontHeightF             = 0.009
res@gsnCenterStringFontHeightF           = 0.009
res@gsnRightStringFontHeightF            = 0.007
res@lbLabelFontHeightF                   = 0.007
res@lbTitleFontHeightF                   = 0.007
res@lbTitlePosition                      = "right"
res@lbTitleDirection                     = "Across"
res@mpCenterLonF                         = 180

res@gsnLeftStringOrthogonalPosF          = 0.0
res@gsnLeftStringParallelPosF            = 0.00

res@tmXBLabelFont                        = "times-roman"
res@tmYLLabelFont                        = "times-roman"
res@gsnStringFont                        = "times-roman"
res@lbLabelFont                          = "times-roman"
res@lbTitleFont                          = "times-roman"
res@tiYAxisFont                          = "times-roman"
res@tiXAxisFont                          = "times-roman"

res@vpWidthF                             = 0.39
res@vpHeightF                            = 0.28

res@cnLevelSelectionMode                 = "ManualLevels"

;res@cnLevelSelectionMode                 = "ExplicitLevels" ;"ManualLevels"
res@cnMinLevelValF                       = -2.0
res@cnMaxLevelValF                       = 30.0
res@cnLevelSpacingF                      =  2.0

;res@mpMaxLatF                            = 90
;res@mpMinLatF                            = 30
;res@mpMaxLonF                            = 30
;res@mpMinLonF                            = -105

res@pmLabelBarHeightF                   = 0.20
res@pmLabelBarWidthF                    = 0.03
res@pmLabelBarOrthogonalPosF            = 0.02
res@pmLabelBarParallelPosF              = 0.5
res@gsnLeftStringOrthogonalPosF         = -0.006
;res@gsnLeftStringParallelPosF           = 0.0
res@gsnRightStringOrthogonalPosF        = 0.007
;res@gsnRightStringParallelPosF          = 0.00
res@gsnCenterStringOrthogonalPosF       = 0.010
;res@gsnCenterStringParallelPosF         = 0.00
res@lbLabelBarOn                        = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


res1                                     = res
res1@vpXF                                = 0.06
res1@vpYF                                = 0.73
res1@gsnLeftString                       = " (a) FGOALS-g3"
res1@gsnRightString                      = " SST"
res1@gsnCenterString                      = " ensmean"
;res1@tmXBLabelsOn                        = False
; plot(1)                                  = gsn_csm_contour_map(wks,ts1(:,:),res1)

; draw(plot(1))

delete(plot_color)
plot_color         = "cmp_b2r"
gsn_define_colormap(wks,plot_color)

res0                                     = True
res0@gsnDraw                             = False
res0@gsnFrame                            = False
res0@cnFillOn                            = False
res0@cnLineLabelsOn                      = True
res0@cnInfoLabelOn                       = False
res0@cnLabelMasking                       = True
res0@cnLineLabelBackgroundColor           = "transparent"
res0@cnLinesOn                           = True
res0@cnLineLabelDensityF                  = 2
res0@cnLineLabelInterval                  = 1
;res0@cnLevelSelectionMode                = "ExplicitLevels"
;res0@cnLevels                            = (/-2.0,0.0,2.0/)
res0@cnLevelSelectionMode                 = "ExplicitLevels" ;"ManualLevels"
res0@gsnContourNegLineDashPattern        = 1
res0@gsnContourZeroLineThicknessF        = 2
res0@gsnLeftString                       = ""
res0@gsnRightString                      = ""

res0@tmXBLabelFont                        = "times-roman"
res0@tmYLLabelFont                        = "times-roman"
res0@gsnStringFont                        = "times-roman"
res0@lbLabelFont                          = "times-roman"
res0@lbTitleFont                          = "times-roman"
res0@tiYAxisFont                          = "times-roman"
res0@tiXAxisFont                          = "times-roman"


res0@cnLevels=(/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30.0/)
res0@cnMonoLineThickness=False
res0@cnLineThicknesses = (/3,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1/)

plot11                                   = gsn_csm_contour(wks,ts1(:,:),res0) ; mean state from fgoals-g2
plot12                                   = gsn_csm_contour(wks,ts3(:,:),res0) ; mean state from fgoals-g3

fgoalsg2_diff_obs                        = ts1_diff_ts2 ; rename variable
fgoalsg3_diff_obs                        = ts3_diff_ts2 ; rename variable
delete([/ts1_diff_ts2, ts3_diff_ts2/])

res2                                     = res
res2@tmXTOn                              = False
res2@tmXBLabelsOn                        = True
res2@tmXBLabelFontHeightF                = 0.013
res2@tmYLLabelFontHeightF                = 0.013
res2@vpXF                                = 0.3
res2@vpYF                                = 0.62
res2@cnMinLevelValF                       = -3.0
res2@cnMaxLevelValF                       =  3.0
res2@cnLevelSpacingF                      =  0.5
res2@tmXBLabelFont                        = "times-roman"
res2@tmYLLabelFont                        = "times-roman"
res2@gsnStringFont                        = "times-roman"
res2@lbLabelFont                          = "times-roman"
res2@lbTitleFont                          = "times-roman"
res2@tiYAxisFont                          = "times-roman"
res2@tiXAxisFont                          = "times-roman"
res2@gsnLeftStringFontHeightF            = 0.011
res2@gsnRightStringFontHeightF           = 0.011
res2@gsnCenterStringFontHeightF          = 0.011
res2@gsnLeftString                       = " (b) FGOALS-g2 minus Obs"

res2@tmXBMode                           = "Explicit"
res2@tmXBValues                         = (/0,45,90,135,180,225,270,315,360/)
res2@tmXBLabels                         = (/"0~S~o","","90~S~o~N~E","","180~S~o","","90~S~o~N~W","","0"/)
res2@tmXBMinorValues                    = fspan(0,360,9)

res2@lbLabelFontHeightF                   = 0.013

res2@gsnCenterStringParallelPosF          = 0.8
res2@gsnCenterStringOrthogonalPosF        = 0.1
res2@gsnRightString                       = "Max = "+sprintf("%5.2f",max(fgoalsg2_diff_obs ))+" Min = "+sprintf("%5.2f",min(fgoalsg2_diff_obs))
res2@gsnCenterString                      = "RMSE = "+sprintf("%5.2f",rms1)+" Mean = "+sprintf("%5.2f",max(mean1)) 
plot(2)                                  = gsn_csm_contour_map(wks,fgoalsg2_diff_obs,res2)
overlay(plot(2),plot11)
draw(plot(2))

res3                                     = res
res3@lbLabelFontHeightF                  = 0.013
res3@tmXTOn                             = False
res3@tmXBMode                           = "Explicit"
res3@tmXBValues                         = (/0,45,90,135,180,225,270,315,360/)
res3@tmXBLabels                         = (/"0~S~o","","90~S~o~N~E","","180~S~o","","90~S~o~N~W","","0"/)
res3@tmXBMinorValues                    = fspan(0,360,9)
res3@gsnLeftStringFontHeightF            = 0.011
res3@gsnRightStringFontHeightF           = 0.011
res3@gsnCenterStringFontHeightF          = 0.011
res3@tmXBLabelFontHeightF                = 0.013
res3@tmYLLabelFontHeightF                = 0.013
res3@vpXF                                = 0.3
res3@vpYF                                = 0.9
res3@cnMinLevelValF                       = -3.0
res3@cnMaxLevelValF                       =  3.0
res3@cnLevelSpacingF                      =  0.5
res3@gsnLeftString                       = " (a) FGOALS-g3 minus Obs"
res3@gsnCenterStringOrthogonalPosF         = 0.1 ; move upward or downward
res3@gsnCenterStringParallelPosF           = 0.8 ; move leftward or rightward
res3@gsnCenterString                       = "RMSE = "+sprintf("%5.2f",rms11)+" Mean = "+sprintf("%5.2f",max(mean11) )
res3@gsnRightStringOrthogonalPosF         = 0. ; move upward or downward
; res3@gsnRightStringParallelPosF           = 0.01 ; move leftward or rightward
res3@gsnRightString                       = "Max = "+sprintf("%5.2f",max(fgoalsg3_diff_obs))+" Min = "+sprintf("%5.2f",min(fgoalsg3_diff_obs))

; res3@gsnRightString                       = "RMSE = "+sprintf("%5.2f",rms11)+" Mean = "+sprintf("%5.2f",max(mean11))+" Max = "+sprintf("%5.2f",max(fgoalsg3_diff_obs))+" Min = "+sprintf("%5.2f",min(fgoalsg3_diff_obs))
plot(3)                                  = gsn_csm_contour_map(wks,fgoalsg3_diff_obs,res3)
overlay(plot(3),plot12)
draw(plot(3))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
frame(wks)

end







