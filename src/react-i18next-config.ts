import LanguageDetector from 'i18next-browser-languagedetector';
import Backend from 'i18next-http-backend';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import enUS from './locales/en-US.json';
import zhTW from './locales/zh-TW.json';

const resources = {
  "en": {
    translation: enUS
  },
  "zh-TW": {
    translation: zhTW 
  },
};

i18n
  .use(Backend)
  .use(LanguageDetector) // Detect current browser language
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'en-US',
    react: {
      useSuspense: false
    },
    debug: false,
    interpolation: {
      escapeValue: false // not needed for react as it escapes by default
    },
    detection: {
      caches: ['localStorage', 'sessionStorage', 'cookie']
    }
  });

export default i18n;
