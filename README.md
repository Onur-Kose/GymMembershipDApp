# Gym Membership DApp

## Giriş
Bu proje, kullanıcıların çeşitli spor salonlarına üye olabilecekleri ve üyeliklerini yönetebilecekleri merkeziyetsiz bir uygulamadır (DApp). 
Proje, Solidity ile yazılmıştır ve Scroll Sepolia testnet üzerinde çalışmaktadır.

## Proje Hedefleri
- **DApp Konsepti**: Scroll blockchain'in yeteneklerini kullanarak yenilikçi bir DApp konsepti geliştirmek.
- **Solidity Kontratı Geliştirme**: DApp'in ana işlevselliğini sağlayacak Solidity akıllı kontratını tasarlamak ve uygulamak.
- **Scroll Sepolia Dağıtımı**: DApp kontratını Scroll Sepolia testnet üzerinde dağıtmak.

## Proje Amacı
- Spor salonalrı ve ve kullancılar için daha esnek çözümler sunmak.
- Kullanıcılar gililik odaklı serviz sağlamak.
- Yinelenen bilgi paylaşımının önüne geçerek kurum ve mekan farketmeyen devamlı gelişim bilgisine erişim sağlamka.


## Kullanılan Teknolojiler
- Solidity
- Hardhat
- Scroll Sepolia testnet

## Kontrat Fonksiyonları
### Üyelik
- **registerMember**: Bir kullanıcının spor salonuna üye olmasını sağlar.
- **manualAddMember**: Spor salonlarının manuel olarak üye eklemesini sağlar.

### Spor Salonu Kayıt
- **registerGym**: Spor salonlarının sisteme kaydolmasını sağlar.

### Abonelik
- **subscribeGym**: Kullanıcıların spor salonlarına belirli bir süre için abone olmasını sağlar.
- **addVisit**: Kullanıcıların spor salonunu ziyaret ettiğini kaydeder.

### Oylama ve Değerlendirme
- **rateGym**: Kullanıcıların spor salonlarını değerlendirmesini sağlar.

## Gereksinimler
- Node.js ve npm
- Hardhat
- MetaMask cüzdanı Scroll Sepolia testnet'e bağlı


### Scroll Sepolia Testnet
Kontrat, Scroll Sepolia testnet üzerinde dağıtılmıştır. Aşağıda detaylar verilmiştir:

- **Kontrat Adresi**: `0x7ca0d0088db3195417e35d9d072d4b4373679820`


## Frontent 
-Frontent için an klasör yapısı oluşturulmuş fakat henüz tamamlnamamıştır.
-Daha iyi yükleme süreleri ve rectif yapısı sebbeiyle reac.js tercih etilmiştir. 
