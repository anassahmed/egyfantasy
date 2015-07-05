			<!-- footer -->
			%from db import *
			%setup_all()
			</div><!-- #content -->
			<div id="footer">
				<div id="siteLinks">
					<h4>روابط هامة</h4>
					<ul>
					<li class="home"><a href="{{rq.script}}/">الرئيسية</a></li>
					<li class="blog"><a href="{{rq.script}}/blog/">المدونة</a></li>
					<li class="rules"><a href="{{rq.script}}/rules/">الدستور</a></li>
					<li class="about"><a href="{{rq.script}}/about/">حول</a></li>
					<li class="contact"><a href="{{rq.script}}/contact/">اتصل بنا</a></li>
					</ul>
				</div><!-- #siteLinks -->
				<div id="follow">
					<h4>تـــابعنا</h4>
					<ul>
					<li><a href="http://www.facebook.com/Anass.Linux" target="_blank"><img src="{{rq.script}}/images/follow_facebook.png" alt="facebook" title="facebook" /></a></li>
					<li><a href="http://www.twitter.com/AnassAhmed" target="_blank"><img src="{{rq.script}}/images/follow_twitter.png" alt="twitter" title="twitter" /></a></li>
					<!--<li><a href="http://www.identi.ca/anassahmed" target="_blank"><img src="{{rq.script}}/images/identica.png" alt="identi.ca" title="identi.ca" /></a></li>-->
					</ul>
				</div><!-- #follow -->
				<div id="copyright">
					<h4>برمجة وتصميم</h4>
					<ul>
					<li><label>برمجة: </label><span><a href="http://anassahmed.tk/" target="_blank">أنس أحمد</a></span></li>
					<li><label>تصميم: </label><span>عمر علي</span></li>
					<li><label>برنامج: </label><span>الخيال المصري</span></li>
					<li><label>الإصدار: </label><span>0.1 preAlpha</span></li>
					</ul>
				</div><!-- #copyright -->
				<div id="statistics">
					<h4>إحصـــائيات</h4>
					<ul>
					<li><label>عدد الأعضاء:</label><span> {{users.query.count()}} عضوًا/أعضاء.</span></li>
					<li><label>عدد الأحزاب:</label><span> {{party.query.count()}} حزبًا/أحزاب.</span></li>
					<li><label>عدد الإشعارات:</label><span> {{notice.query.count()}} إشعارًا/إشعارات.</span></li>
					<li><label>عدد المواضيع:</label><span> {{topic.query.count()}} موضوعًا/موضوعات.</span></li>
					</ul>
				</div>
			</div><!-- #footer -->
		</div><!-- #wrap -->
	</body>
</html>